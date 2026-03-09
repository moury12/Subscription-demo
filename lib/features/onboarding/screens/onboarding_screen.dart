import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/branding/gradient_logo.dart';
import '../../../widgets/navigation/pagination_dots.dart';
import '../../auth/screens/sign_in_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Calculate scale factor based on Figma design (393x851.87)
    final designWidth = 393.0;
    final scale = (screenWidth / designWidth).clamp(0.8, 1.5);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Blurred background circles - scaled to screen
          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  left: 98.31 * scale,
                  top: 212.97 * scale,
                  child: Container(
                    width: 384 * scale,
                    height: 384 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA).withValues(alpha: 0.497426),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -89.05 * scale,
                  top: 254.91 * scale,
                  child: Container(
                    width: 384 * scale,
                    height: 384 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.31587),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content - centered with intrinsic sizing
          Center(
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  const GradientLogo(
                    size: AppSpacing.splashLogoSize,
                    borderRadius: AppSpacing.splashLogoRadius,
                    // Use Flutter-native gradient instead of SVG with unsupported filters
                  ),

                  const SizedBox(height: AppSpacing.splashLogoToTitle),

                  // Title
                  const Text(
                    'FitnessPro',
                    style: AppTextStyles.splashTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.splashTitleToSubtitle),

                  // Subtitle
                  const Text(
                    'Your AI Fitness Companion',
                    style: AppTextStyles.splashSubtitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.splashSubtitleToDots),

                  // Pagination dots
                  const PaginationDots(
                    totalDots: 3,
                    currentIndex: 0,
                  ),
                ],
              ),
            ),
          ),

          // Tap area to navigate to sign in
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
