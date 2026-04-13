import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

/// Notification ID constants for deterministic cancel/replace.
abstract class NotificationIds {
  static const int waterReminder = 1000;

  static const int breakfastSoft = 2001;
  static const int breakfastFinal = 2002;
  static const int lunchSoft = 2003;
  static const int lunchFinal = 2004;
  static const int dinnerSoft = 2005;
  static const int dinnerFinal = 2006;

  static const int workoutFirst = 3001;
  static const int workoutFinal = 3002;
}

/// Preference keys for notification toggle persistence.
abstract class _PrefKeys {
  static const String masterEnabled = 'notif_master';
  static const String waterEnabled = 'notif_water';
  static const String mealEnabled = 'notif_meal';
  static const String workoutEnabled = 'notif_workout';
  static const String lastScheduledDate = 'notif_last_date';
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ──────────────────────── Channels ────────────────────────

  static const _waterChannel = AndroidNotificationChannel(
    'water_reminders',
    'Water Reminders',
    description: 'Hydration reminders throughout the day',
    importance: Importance.high,
  );

  static const _mealChannel = AndroidNotificationChannel(
    'meal_reminders',
    'Meal Reminders',
    description: 'Reminders to log your meals',
    importance: Importance.high,
  );

  static const _workoutChannel = AndroidNotificationChannel(
    'workout_reminders',
    'Workout Reminders',
    description: 'Reminders for your daily workout',
    importance: Importance.high,
  );

  // ──────────────────────── Init ────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_resolveTimezone()));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
            _toAndroidDetails(_waterChannel));
        await androidPlugin.createNotificationChannel(
            _toAndroidDetails(_mealChannel));
        await androidPlugin.createNotificationChannel(
            _toAndroidDetails(_workoutChannel));
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    _initialized = true;
    debugPrint('[NOTIF] NotificationService initialized');
  }

  // ──────────────────────── Scheduling helpers ────────────────────────

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AndroidNotificationChannel channel,
  }) async {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return;

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint('[NOTIF] Scheduled #$id "$title" at $scheduledTime');
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('[NOTIF] Cancelled #$id');
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('[NOTIF] Cancelled all notifications');
  }

  // ──────────────────────── Channel accessors ────────────────────────

  AndroidNotificationChannel get waterChannel => _waterChannel;
  AndroidNotificationChannel get mealChannel => _mealChannel;
  AndroidNotificationChannel get workoutChannel => _workoutChannel;

  // ──────────────────────── Preference management ────────────────────────

  Future<void> setMasterEnabled(bool v) async =>
      (await SharedPreferences.getInstance())
          .setBool(_PrefKeys.masterEnabled, v);
  Future<void> setWaterEnabled(bool v) async =>
      (await SharedPreferences.getInstance())
          .setBool(_PrefKeys.waterEnabled, v);
  Future<void> setMealEnabled(bool v) async =>
      (await SharedPreferences.getInstance())
          .setBool(_PrefKeys.mealEnabled, v);
  Future<void> setWorkoutEnabled(bool v) async =>
      (await SharedPreferences.getInstance())
          .setBool(_PrefKeys.workoutEnabled, v);

  Future<bool> get isMasterEnabled async =>
      (await SharedPreferences.getInstance())
          .getBool(_PrefKeys.masterEnabled) ??
      true;
  Future<bool> get isWaterEnabled async =>
      (await SharedPreferences.getInstance())
          .getBool(_PrefKeys.waterEnabled) ??
      false;
  Future<bool> get isMealEnabled async =>
      (await SharedPreferences.getInstance())
          .getBool(_PrefKeys.mealEnabled) ??
      false;
  Future<bool> get isWorkoutEnabled async =>
      (await SharedPreferences.getInstance())
          .getBool(_PrefKeys.workoutEnabled) ??
      false;

  Future<String?> get lastScheduledDate async =>
      (await SharedPreferences.getInstance())
          .getString(_PrefKeys.lastScheduledDate);

  Future<void> setLastScheduledDate(String date) async =>
      (await SharedPreferences.getInstance())
          .setString(_PrefKeys.lastScheduledDate, date);

  // ──────────────────────── Private helpers ────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NOTIF] Tapped: ${response.id} / ${response.payload}');
  }

  String _resolveTimezone() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours;
      if (hours >= 5 && hours <= 6) return 'Asia/Kolkata';
      if (hours == 0) return 'Europe/London';
      if (hours == -5) return 'America/New_York';
      if (hours == -8) return 'America/Los_Angeles';
      return 'UTC';
    } catch (_) {
      return 'UTC';
    }
  }

  AndroidNotificationChannelGroup? _toGroup(AndroidNotificationChannel c) =>
      null;

  AndroidNotificationChannel _toAndroidDetails(
          AndroidNotificationChannel c) =>
      c;
}
