import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/localization_service.dart';

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
import '../../subscription/screens/subscription_plan_screen.dart';

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
            // Sync language to provider so it updates the whole app UI
            final langCode = LocalizationService().currentLanguageCode;
            context.read<LanguageProvider>().syncLanguage(langCode);

            final hasSelectedSub = profile['hasSelectedSubscription'] == true;
            if (!hasSelectedSub) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SubscriptionPlanScreen()),
                (route) => false,
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MainShellScreen(),
                  settings: const RouteSettings(name: '/main'),
                ),
                (route) => false,
              );
            }
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
    final l = context.watch<LanguageProvider>();
    return AuthScaffold(
      child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const SizedBox(height: 40),
            AuthHeader(
              title: l.getString('auth.welcome_back'),
              subtitle: l.getString('auth.sign_in_subtitle'),
            ),
            const SizedBox(height: AppSpacing.authHeaderGap),
            AppTextInput(
              controller: _emailController,
              hint: l.getString('auth.email'),
              svgIcon: 'assets/icons/email_icon.svg',
            ),
            const SizedBox(height: AppSpacing.authFormGap),
            AppTextInput(
              controller: _passwordController,
              hint: l.getString('auth.password'),
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
                child: Text(l.getString('auth.forgot_password_q'), style: AppTextStyles.authHelp),
              ),
            ),
            const SizedBox(height: AppSpacing.authForgotToButton),
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : PrimaryGlowButton(
                  label: l.getString('auth.sign_in'),
                  onPressed: _handleSignIn,
                ),
            const SizedBox(height: AppSpacing.lg),
            AuthCtaRow(
              label: l.getString('auth.no_account_label') + ' ',
              action: l.getString('auth.sign_up'),
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
