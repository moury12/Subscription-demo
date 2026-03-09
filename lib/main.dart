import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() {
  runApp(const RamsaiApp());
}

class RamsaiApp extends StatelessWidget {
  const RamsaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramsai',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const OnboardingScreen(),
    );
  }
}
