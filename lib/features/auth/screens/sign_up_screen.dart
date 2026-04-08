import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/inputs/app_text_input.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../../../screens/onboarding/onboarding_flow_screen.dart';
import '../services/auth_service.dart';
import '../../profile/services/profile_service.dart';
import '../../main/screens/main_shell_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await AuthService().signup(email, password, name);
    
    if (mounted) {
      if (success) {
        // Check for existing profile (usually empty for new users)
        final profile = await ProfileService().getProfile();
        if (mounted) {
          setState(() => _isLoading = false);
          if (profile != null && profile['hasCompletedOnboarding'] == true) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainShellScreen()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()));
          }
        }
      } else {
        setState(() => _isLoading = false);
        _showError('Failed to create account. Email may already be in use.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

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
            AppTextInput(
              controller: _nameController,
              hint: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.textSecondary, size: AppSpacing.iconSize),
            ),
            const SizedBox(height: AppSpacing.authSignUpInputGap),
            AppTextInput(
              controller: _emailController,
              hint: 'Email',
              svgIcon: 'assets/icons/email_icon.svg',
            ),
            const SizedBox(height: AppSpacing.authSignUpInputGap),
            AppTextInput(
              controller: _passwordController,
              hint: 'Password',
              svgIcon: 'assets/icons/password_icon.svg',
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.authSignUpInputGap),
            AppTextInput(
              controller: _confirmPasswordController,
              hint: 'Confirm Password',
              svgIcon: 'assets/icons/password_icon.svg',
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : PrimaryGlowButton(
                  label: 'Sign Up',
                  onPressed: _handleSignUp,
                ),
            const SizedBox(height: AppSpacing.md),
            // Terms text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
                  children: [
                    const TextSpan(text: 'By signing up, you agree to our '),
                    TextSpan(
                      text: 'Terms',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrl(Uri.parse('https://github.com')),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrl(Uri.parse('https://github.com')),
                    ),
                  ],
                ),
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
