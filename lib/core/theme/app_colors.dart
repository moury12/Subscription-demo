import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceRaised = Color(0xFF1E1E1E);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary90 = Color.fromRGBO(255, 255, 255, 0.9);
  static const Color textPrimary70 = Color.fromRGBO(255, 255, 255, 0.7);
  static const Color textSecondary = Color.fromRGBO(255, 255, 255, 0.5);
  static const Color textMuted = Color(0xFF4A5565);
  static const Color titleSoft = Color(0xFFD7DFEF);

  static const Color borderSoft = Color.fromRGBO(255, 255, 255, 0.1);
  static const Color inputBorder = Color(0xFF2E333C);
  static const Color overlaySoft = Color.fromRGBO(255, 255, 255, 0.05);
  static const Color overlayMedium = Color.fromRGBO(255, 255, 255, 0.1);

  static const Color brandPrimary = Color(0xFF2E6FFC);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentBlueDark = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentOrange = Color(0xFFFB923C);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentBlue, accentBlueDark],
  );

  static const LinearGradient splashLogoGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentBlue, accentPurple],
  );
}
