import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/branding/gradient_logo.dart';
import '../../../widgets/navigation/pagination_dots.dart';
import '../../auth/screens/auth_choice_screen.dart';
import '../../../screens/onboarding/onboarding_flow_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/services/profile_service.dart';
import '../../main/screens/main_shell_screen.dart';
import '../../../core/app_settings.dart';
import '../../../screens/onboarding/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Show splash for at least 1.5s
    final startTime = DateTime.now();
    
    final isLoggedIn = await AuthService().isLoggedIn();
    
    if (isLoggedIn) {
      debugPrint('[SPLASH] User is logged in, fetching profile...');
      final profile = await ProfileService().getProfile();
      
      // Calculate remaining delay
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed < 1500) {
        await Future.delayed(Duration(milliseconds: 1500 - elapsed));
      }

      if (mounted) {
        if (profile != null && profile['hasCompletedOnboarding'] == true) {
          debugPrint('[SPLASH] Profile complete. Going to Dashboard.');
          AppSettings().syncFromProfile(profile);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShellScreen()),
          );
        } else if (profile != null) {
          debugPrint('[SPLASH] Profile incomplete. Going to Onboarding Survey.');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
          );
        } else {
          // If profile fetch fails (like a 401 or network error), treat as Guest
          debugPrint('[SPLASH] Profile fetch failed. Redirecting to Landing.');
          await AuthService().logout(); // Clear stale token
          _goToLanding();
        }
      }
    } else {
      debugPrint('[SPLASH] User is a Guest. Redirecting to Landing.');
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        _goToLanding();
      }
    }
  }

  void _goToLanding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => WelcomeScreen(
          onStart: () {
            debugPrint('[LANDING] Get Started clicked. Going to Auth Choice.');
            Navigator.of(ctx).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthChoiceScreen()));
          },
          onSkip: () {
            debugPrint('[LANDING] Skip clicked. Going to Auth Choice.');
            Navigator.of(ctx).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthChoiceScreen()));
          },
        ),
      ),
    );
  }


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

          // Main content - centered
          Center(
            child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  const GradientLogo(
                    size: AppSpacing.splashLogoSize,
                    borderRadius: AppSpacing.splashLogoRadius,
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

        ],
      ),
    );
  }
}
