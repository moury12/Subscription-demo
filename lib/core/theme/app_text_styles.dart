import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle authTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.titleSoft,
  );

  static const TextStyle authSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.2102272510528564,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle authHelp = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 1.4285714285714286,
    fontWeight: FontWeight.w500,
    color: AppColors.brandPrimary,
  );

  static const TextStyle authAction = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.brandPrimary,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    height: 1.5555555555555556,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle value20 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body14Soft = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 1.4285714285714286,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary90,
  );

  static const TextStyle caption70 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    height: 1.3333333333333333,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary70,
  );

  static const TextStyle h1 = authTitle;

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    height: 1.4545,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle valueLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle valueMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    height: 1.3333,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 1.4285,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 1.4285,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    height: 1.3333,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary90,
  );

  // Onboarding/Splash Screen Styles
  static const TextStyle splashTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    height: 1.1111111111111112,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: Color.fromRGBO(255, 255, 255, 0.8),
  );

  static const TextStyle statusBarTime = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.396,
    color: AppColors.textPrimary,
  );
}
