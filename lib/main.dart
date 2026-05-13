import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_scheduler.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const GocalAiApp());
}

class GocalAiApp extends StatelessWidget {
  const GocalAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoCal AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          // Use HitTestBehavior.opaque so that the gesture detector catches taps
          // even when the rest of the UI doesn't explicitly catch them.
          // Wait, 'translucent' is better so it doesn't block hits beneath.
          behavior: HitTestBehavior.translucent,
          child: child!,
        );
      },
      home: const OnboardingScreen(),
    );
  }
}
