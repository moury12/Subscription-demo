import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderSoft, width: 1.1),
      ),
      padding: padding,
      child: child,
    );
  }
}
