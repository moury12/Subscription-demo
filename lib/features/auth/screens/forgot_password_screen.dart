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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                // Top header with Back button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Back',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Center the forgot password content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AuthHeader(
                            title: 'Forgot Password?',
                            subtitle:
                                'Enter your email and we\'ll send you instructions to reset your password',
                            showLogo: false,
                          ),
                          const SizedBox(height: AppSpacing.authHeaderGap),
                          const AppTextInput(
                            hint: 'Email',
                            svgIcon: 'assets/icons/email_icon.svg',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          PrimaryGlowButton(
                            label: 'Send Reset Link',
                            onPressed: () {
                              // Action to send reset link
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
