import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/inputs/app_text_input.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../../../screens/onboarding/onboarding_flow_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const AuthHeader(
              title: 'Create Account',
              subtitle: 'Start your fitness journey today',
            ),
            const SizedBox(height: AppSpacing.authHeaderGap),
            // Full Name input
            const AppTextInput(
              hint: 'Full Name',
              prefixIcon: Icon(Icons.person_outline,
                  color: AppColors.textSecondary, size: AppSpacing.iconSize),
            ),
            const SizedBox(height: AppSpacing.authSignUpInputGap),
            // Email input with SVG icon
            const AppTextInput(
              hint: 'Email',
              svgIcon: 'assets/icons/email_icon.svg',
            ),
            const SizedBox(height: AppSpacing.authSignUpInputGap),
            // Password input with SVG icon
            const AppTextInput(
              hint: 'Password',
              svgIcon: 'assets/icons/password_icon.svg',
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.authSignUpInputGap),
            // Confirm Password input with SVG icon
            const AppTextInput(
              hint: 'Confirm Password',
              svgIcon: 'assets/icons/password_icon.svg',
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryGlowButton(
                label: 'Sign Up',
                onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                    )),
            const SizedBox(height: AppSpacing.md),
            // Terms text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'By signing up, you agree to our Terms and Privacy Policy',
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthCtaRow(
              label: 'Already have an account? ',
              action: 'Sign In',
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
