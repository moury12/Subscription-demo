import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/inputs/app_text_input.dart';
import '../../../screens/onboarding/onboarding_flow_screen.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AuthHeader(
            title: 'Welcome Back',
            subtitle: 'Sign in to continue your fitness journey',
          ),
          const SizedBox(height: AppSpacing.authHeaderGap),
          // Email input with SVG icon
          const AppTextInput(
            hint: 'Email',
            svgIcon: 'assets/icons/email_icon.svg',
          ),
          const SizedBox(height: AppSpacing.authFormGap),
          // Password input with SVG icon
          const AppTextInput(
            hint: 'Password',
            svgIcon: 'assets/icons/password_icon.svg',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.authForgotGap),
          // Forgot Password - centered as per Figma
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
              },
              child: const Text('Forgot Password?', style: AppTextStyles.authHelp),
            ),
          ),
          const SizedBox(height: AppSpacing.authForgotToButton),
          PrimaryGlowButton(
            label: 'Sign In',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()));
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthCtaRow(
            label: 'Don\'t have an account? ',
            action: 'Sign Up',
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()));
            },
          ),
        ],
      ),
    );
  }
}
