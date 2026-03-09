import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.authVertical,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthCtaRow extends StatelessWidget {
  const AuthCtaRow({
    required this.label,
    required this.action,
    required this.onTap,
    super.key,
  });

  final String label;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: AppTextStyles.authSubtitle.copyWith(color: AppColors.textMuted)),
        TextButton(
          onPressed: onTap,
          child: Text(action, style: AppTextStyles.authAction),
        ),
      ],
    );
  }
}
