import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo from Figma (63.99 x 63.99)
        SizedBox(
          width: AppSpacing.authLogoSize,
          height: AppSpacing.authLogoSize,
          child: SvgPicture.asset(
            'assets/icons/auth_logo.svg',
            width: AppSpacing.authLogoSize,
            height: AppSpacing.authLogoSize,
          ),
        ),
        const SizedBox(height: AppSpacing.authLogoToTitle),
        Text(title, style: AppTextStyles.authTitle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.authTitleToSubtitle),
        Text(subtitle, style: AppTextStyles.authSubtitle, textAlign: TextAlign.center),
      ],
    );
  }
}
