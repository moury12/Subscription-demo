import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        surface: AppColors.surface,
      ),
    );
  }
}
