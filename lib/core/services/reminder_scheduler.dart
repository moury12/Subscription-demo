import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import '../../features/nutrition/controllers/nutrition_controller.dart';
import '../../features/workout/controllers/workout_controller.dart';

/// Orchestrates all smart reminder scheduling.
///
/// Designed to be called from anywhere (controllers, lifecycle hooks) without
/// tight coupling — only depends on singletons that already exist.
class ReminderScheduler {
  static final ReminderScheduler _instance = ReminderScheduler._internal();
  factory ReminderScheduler() => _instance;
  ReminderScheduler._internal();

  final NotificationService _notif = NotificationService();

  // ──────────────────────── Public API ────────────────────────

  /// One-shot call on app launch / resume. Schedules only the reminders the
  /// user has opted-in to and that haven't been fulfilled today yet.
  Future<void> scheduleTodayNotifications() async {
    final master = await _notif.isMasterEnabled;
    if (!master) {
      await _notif.cancelAllNotifications();
      return;
    }

    final today = _todayKey();
    final lastDate = await _notif.lastScheduledDate;

    if (lastDate == today) {
      debugPrint('[SCHED] Already scheduled for $today, skipping full run');
      return;
    }

    await _notif.cancelAllNotifications();

    if (await _notif.isWaterEnabled) await scheduleWaterReminder();
    if (await _notif.isMealEnabled) await scheduleMealReminders();
    if (await _notif.isWorkoutEnabled) await scheduleWorkoutReminder();

    await _notif.setLastScheduledDate(today);
    debugPrint('[SCHED] Scheduled all reminders for $today');
  }

  /// Force reschedule (e.g. after toggle change). Ignores the date guard.
  Future<void> forceReschedule() async {
    await _notif.cancelAllNotifications();

    final master = await _notif.isMasterEnabled;
    if (!master) return;

    if (await _notif.isWaterEnabled) await scheduleWaterReminder();
    if (await _notif.isMealEnabled) await scheduleMealReminders();
    if (await _notif.isWorkoutEnabled) await scheduleWorkoutReminder();

    await _notif.setLastScheduledDate(_todayKey());
    debugPrint('[SCHED] Force-rescheduled all reminders');
  }

  // ──────────────────────── Water ────────────────────────

  /// Schedules the next water reminder 2 hours after [lastLogTime].
  /// Clamps between 8 AM – 10 PM; rolls to next-day 8 AM if needed.
  Future<void> scheduleNextWaterReminder(DateTime lastLogTime) async {
    final master = await _notif.isMasterEnabled;
    final enabled = await _notif.isWaterEnabled;
    if (!master || !enabled) return;

    await _notif.cancelNotification(NotificationIds.waterReminder);

    var next = lastLogTime.add(const Duration(hours: 2));
    final todayStart = _dateOnly(next);
    final morningLimit =
        todayStart.add(const Duration(hours: 8));
    final nightLimit =
        todayStart.add(const Duration(hours: 22));

    if (next.isAfter(nightLimit)) {
      next = todayStart
          .add(const Duration(days: 1, hours: 8));
    } else if (next.isBefore(morningLimit)) {
      next = morningLimit;
    }

    await _notif.scheduleNotification(
      id: NotificationIds.waterReminder,
      title: 'Stay Hydrated',
      body: 'Time to drink some water! Your body needs it.',
      scheduledTime: next,
      channel: _notif.waterChannel,
    );
  }

  /// Initial water reminder — schedules from now + 2 hours.
  Future<void> scheduleWaterReminder() async {
    await scheduleNextWaterReminder(DateTime.now());
  }

  // ──────────────────────── Meals ────────────────────────

  Future<void> scheduleMealReminders() async {
    final today = DateTime.now();
    final meals = NutritionController().loggedMeals;

    if (!hasLoggedMealTypeToday(meals, 'Breakfast')) {
      await _scheduleMealPair(
        softId: NotificationIds.breakfastSoft,
        finalId: NotificationIds.breakfastFinal,
        mealName: 'Breakfast',
        softTime: _todayAt(today, 9, 30),
        finalTime: _todayAt(today, 11, 0),
      );
    }

    if (!hasLoggedMealTypeToday(meals, 'Lunch')) {
      await _scheduleMealPair(
        softId: NotificationIds.lunchSoft,
        finalId: NotificationIds.lunchFinal,
        mealName: 'Lunch',
        softTime: _todayAt(today, 13, 30),
        finalTime: _todayAt(today, 15, 0),
      );
    }

    if (!hasLoggedMealTypeToday(meals, 'Dinner')) {
      await _scheduleMealPair(
        softId: NotificationIds.dinnerSoft,
        finalId: NotificationIds.dinnerFinal,
        mealName: 'Dinner',
        softTime: _todayAt(today, 20, 30),
        finalTime: _todayAt(today, 22, 30),
      );
    }
  }

  /// Call after a meal is logged to cancel remaining reminders for that type.
  Future<void> onMealLogged(String mealType) async {
    switch (mealType) {
      case 'Breakfast':
        await _notif.cancelNotification(NotificationIds.breakfastSoft);
        await _notif.cancelNotification(NotificationIds.breakfastFinal);
      case 'Lunch':
        await _notif.cancelNotification(NotificationIds.lunchSoft);
        await _notif.cancelNotification(NotificationIds.lunchFinal);
      case 'Dinner':
        await _notif.cancelNotification(NotificationIds.dinnerSoft);
        await _notif.cancelNotification(NotificationIds.dinnerFinal);
    }
  }

  // ──────────────────────── Workout ────────────────────────

  Future<void> scheduleWorkoutReminder() async {
    if (hasLoggedWorkoutToday()) return;

    final today = DateTime.now();
    await _notif.scheduleNotification(
      id: NotificationIds.workoutFirst,
      title: 'Time to Work Out',
      body: "You haven't logged a workout today. Let's get moving!",
      scheduledTime: _todayAt(today, 16, 0),
      channel: _notif.workoutChannel,
    );
    await _notif.scheduleNotification(
      id: NotificationIds.workoutFinal,
      title: "Don't Skip Your Workout",
      body: 'Last reminder — even 15 minutes counts!',
      scheduledTime: _todayAt(today, 18, 0),
      channel: _notif.workoutChannel,
    );
  }

  /// Call after a workout is completed to cancel remaining reminders.
  Future<void> onWorkoutLogged() async {
    await _notif.cancelNotification(NotificationIds.workoutFirst);
    await _notif.cancelNotification(NotificationIds.workoutFinal);
  }

  // ──────────────────────── Cancel helpers ────────────────────────

  Future<void> cancelAllDailyReminders() async {
    await _notif.cancelAllNotifications();
  }

  Future<void> cancelWaterReminders() async {
    await _notif.cancelNotification(NotificationIds.waterReminder);
  }

  Future<void> cancelMealReminders() async {
    await _notif.cancelNotification(NotificationIds.breakfastSoft);
    await _notif.cancelNotification(NotificationIds.breakfastFinal);
    await _notif.cancelNotification(NotificationIds.lunchSoft);
    await _notif.cancelNotification(NotificationIds.lunchFinal);
    await _notif.cancelNotification(NotificationIds.dinnerSoft);
    await _notif.cancelNotification(NotificationIds.dinnerFinal);
  }

  Future<void> cancelWorkoutReminders() async {
    await _notif.cancelNotification(NotificationIds.workoutFirst);
    await _notif.cancelNotification(NotificationIds.workoutFinal);
  }

  // ──────────────────────── Log checks ────────────────────────

  bool hasLoggedMealTypeToday(List<LoggedMeal> meals, String type) {
    return meals.any((m) => m.type == type);
  }

  bool hasLoggedWorkoutToday() {
    return WorkoutController().completedToday > 0;
  }

  // ──────────────────────── Private helpers ────────────────────────

  Future<void> _scheduleMealPair({
    required int softId,
    required int finalId,
    required String mealName,
    required DateTime softTime,
    required DateTime finalTime,
  }) async {
    await _notif.scheduleNotification(
      id: softId,
      title: 'Log Your $mealName',
      body: "Don't forget to log your $mealName to stay on track!",
      scheduledTime: softTime,
      channel: _notif.mealChannel,
    );
    await _notif.scheduleNotification(
      id: finalId,
      title: '$mealName Reminder',
      body: "You still haven't logged $mealName today. Tap to log now.",
      scheduledTime: finalTime,
      channel: _notif.mealChannel,
    );
  }

  DateTime _todayAt(DateTime ref, int hour, int minute) {
    return DateTime(ref.year, ref.month, ref.day, hour, minute);
  }

  DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
