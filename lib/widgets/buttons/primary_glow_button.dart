import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PrimaryGlowButton extends StatelessWidget {
  const PrimaryGlowButton({
    required this.label,
    required this.onPressed,
    this.height = AppSpacing.buttonHeight,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.brandPrimary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(46, 111, 252, 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color.fromRGBO(46, 111, 252, 0.4),
              blurRadius: 24,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: onPressed,
            child: Center(
              child: Text(label, style: AppTextStyles.buttonLabel),
            ),
          ),
        ),
      ),
    );
  }
}
