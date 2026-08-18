import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'navigation_service.dart';

/// Top-level background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Handling background message: ${message.messageId}');
}

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

  static const int broadcastMessage = 4001;
}

/// Preference keys for notification toggle persistence.
abstract class _PrefKeys {
  static const String masterEnabled = 'notif_master';
  static const String waterEnabled = 'notif_water';
  static const String mealEnabled = 'notif_meal';
  static const String workoutEnabled = 'notif_workout';
  static const String broadcastEnabled = 'notif_broadcast';
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

  static const _broadcastChannel = AndroidNotificationChannel(
    'broadcast_reminders',
    'Broadcast & Announcements',
    description: 'System announcements and broadcast updates',
    importance: Importance.max,
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
        await androidPlugin.createNotificationChannel(_waterChannel);
        await androidPlugin.createNotificationChannel(_mealChannel);
        await androidPlugin.createNotificationChannel(_workoutChannel);
        await androidPlugin.createNotificationChannel(_broadcastChannel);
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    // Initialize Firebase Messaging for push notifications
    await _initFirebaseMessaging();

    _initialized = true;
    debugPrint('[NOTIF] NotificationService initialized');
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request push notification permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('[FCM] Notification authorization status: ${settings.authorizationStatus}');

      // Register device FCM token with backend
      await syncFcmToken();

      // Listen for token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM] Token refreshed: $newToken');
        await _sendTokenToBackend(newToken);
      });

      // Handle foreground notifications (show heads-up banner)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground notification received: ${message.messageId}');
        _showForegroundNotification(message);
      });

      // Handle when user taps notification while app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] App opened from background notification: ${message.messageId}');
        NavigationService.navigateToNotifications();
      });

      // Handle when user taps notification while app was terminated
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] App opened from terminated notification: ${initialMessage.messageId}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NavigationService.navigateToNotifications();
        });
      }
    } catch (e) {
      debugPrint('[FCM ERROR] FirebaseMessaging setup failed: $e');
    }
  }

  Future<void> syncFcmToken() async {
    int attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          debugPrint('[FCM] FCM Token fetched successfully: $token');
          await _sendTokenToBackend(token);
          return;
        }
      } catch (e) {
        debugPrint('[FCM ERROR] Attempt $attempts/$maxAttempts failed to fetch FCM token: $e');
        if (attempts < maxAttempts) {
          // Exponential backoff delay (3s, 6s, 9s...) to allow Google Play Services to connect
          await Future.delayed(Duration(seconds: attempts * 3));
        }
      }
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      if (authToken == null || authToken.isEmpty) {
        debugPrint('[FCM] Postponing token sync: user not authenticated yet');
        return;
      }
      final deviceType = Platform.isIOS ? 'ios' : 'android';
      await ApiService().post('/notifications/fcm-token', {
        'token': token,
        'deviceType': deviceType,
      });
      debugPrint('[FCM] Token successfully synced with backend');
    } catch (e) {
      debugPrint('[FCM ERROR] Failed to sync token with backend: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['message'] ?? '';

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _broadcastChannel.id,
          _broadcastChannel.name,
          channelDescription: _broadcastChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
  AndroidNotificationChannel get broadcastChannel => _broadcastChannel;

  // ──────────────────────── Preference management ────────────────────────

  Future<void> setMasterEnabled(bool v) async {
    (await SharedPreferences.getInstance()).setBool(_PrefKeys.masterEnabled, v);
    await syncPreferencesToBackend();
  }

  Future<void> setWaterEnabled(bool v) async {
    (await SharedPreferences.getInstance()).setBool(_PrefKeys.waterEnabled, v);
    await syncPreferencesToBackend();
  }

  Future<void> setMealEnabled(bool v) async {
    (await SharedPreferences.getInstance()).setBool(_PrefKeys.mealEnabled, v);
    await syncPreferencesToBackend();
  }

  Future<void> setWorkoutEnabled(bool v) async {
    (await SharedPreferences.getInstance()).setBool(_PrefKeys.workoutEnabled, v);
    await syncPreferencesToBackend();
  }

  Future<void> setBroadcastEnabled(bool v) async {
    (await SharedPreferences.getInstance()).setBool(_PrefKeys.broadcastEnabled, v);
    await syncPreferencesToBackend();
  }

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

  Future<bool> get isBroadcastEnabled async =>
      (await SharedPreferences.getInstance())
          .getBool(_PrefKeys.broadcastEnabled) ??
      true;

  Future<void> syncPreferencesToBackend() async {
    try {
      final master = await isMasterEnabled;
      final water = await isWaterEnabled;
      final meal = await isMealEnabled;
      final workout = await isWorkoutEnabled;
      final broadcast = await isBroadcastEnabled;

      await ApiService().patch('/notifications/preferences', {
        'preferences': {
          'master': master,
          'drinkWater': water,
          'mealLog': meal,
          'workout': workout,
          'broadcast': broadcast,
        }
      });
      debugPrint('[NOTIF] Synced preferences to backend');
    } catch (e) {
      debugPrint('[NOTIF ERROR] Failed to sync preferences to backend: $e');
    }
  }

  Future<String?> get lastScheduledDate async =>
      (await SharedPreferences.getInstance())
          .getString(_PrefKeys.lastScheduledDate);

  Future<void> setLastScheduledDate(String date) async =>
      (await SharedPreferences.getInstance())
          .setString(_PrefKeys.lastScheduledDate, date);

  // ──────────────────────── Private helpers ────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NOTIF] Tapped: ${response.id} / ${response.payload}');
    NavigationService.navigateToNotifications();
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
}
