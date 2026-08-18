import 'package:flutter/material.dart';
import '../../features/notifications/screens/all_notifications_screen.dart';

abstract class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigate to the Notifications screen
  static Future<void> navigateToNotifications() async {
    final state = navigatorKey.currentState;
    if (state != null) {
      await state.push(
        MaterialPageRoute(
          builder: (_) => const AllNotificationsScreen(),
        ),
      );
    }
  }
}
