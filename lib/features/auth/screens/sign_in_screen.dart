import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/user_data_sync.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/inputs/app_text_input.dart';
import '../../../screens/onboarding/onboarding_flow_screen.dart';
import '../../../core/app_settings.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../services/auth_service.dart';
import '../../profile/services/profile_service.dart';
import '../../main/screens/main_shell_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await AuthService().login(email, password);
    
    if (mounted) {
      if (success) {
        // Check for existing profile
        final profile = await ProfileService().getProfile();
        if (mounted) {
          setState(() => _isLoading = false);
          if (profile != null && profile['hasCompletedOnboarding'] == true) {
            AppSettings().syncFromProfile(profile);
            await UserDataSync.loadAll();
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainShellScreen()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()));
          }
        }
      } else {
        setState(() => _isLoading = false);
        _showError('Invalid email or password');
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
          children: [
            const SizedBox(height: 40),
            const AuthHeader(
              title: 'Welcome Back',
              subtitle: 'Sign in to continue your fitness journey',
            ),
            const SizedBox(height: AppSpacing.authHeaderGap),
            AppTextInput(
              controller: _emailController,
              hint: 'Email',
              svgIcon: 'assets/icons/email_icon.svg',
            ),
            const SizedBox(height: AppSpacing.authFormGap),
            AppTextInput(
              controller: _passwordController,
              hint: 'Password',
              svgIcon: 'assets/icons/password_icon.svg',
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.authForgotGap),
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
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : PrimaryGlowButton(
                  label: 'Sign In',
                  onPressed: _handleSignIn,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
