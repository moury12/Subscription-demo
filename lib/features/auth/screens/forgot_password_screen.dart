import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/inputs/app_text_input.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Back button row aligned left
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  iconSize: AppSpacing.iconSize,
                ),
                Text(
                  'Back',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 31.99),
            const AuthHeader(
              title: 'Forgot Password?',
              subtitle:
                  'Enter your email and we\'ll send you instructions to reset your password',
            ),
            const SizedBox(height: AppSpacing.authHeaderGap),
            // Email input with SVG icon
            const AppTextInput(
              hint: 'Email',
              svgIcon: 'assets/icons/email_icon.svg',
            ),
            const SizedBox(height: 15.99),
            PrimaryGlowButton(
                label: 'Send Reset Link',
                onPressed: () => Navigator.of(context).pop()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
