import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// Reusable gradient logo widget with glow effect
class GradientLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final Gradient gradient;
  final List<BoxShadow>? shadows;
  final Widget? child;
  final String? svgAsset;

  const GradientLogo({
    super.key,
    this.size = AppSpacing.splashLogoSize,
    this.borderRadius = AppSpacing.splashLogoRadius,
    this.gradient = AppColors.splashLogoGradient,
    this.shadows,
    this.child,
    this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    // If SVG asset is provided, use it directly (it contains gradient and glow)
    if (svgAsset != null) {
      return SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          svgAsset!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    }

    // Fallback to gradient container with icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? _defaultShadows,
      ),
      child: child ?? _defaultLogoContent(),
    );
  }

  Widget _defaultLogoContent() {
    return const Center(
      child: Icon(
        Icons.fitness_center_rounded,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  static final List<BoxShadow> _defaultShadows = [
    BoxShadow(
      color: AppColors.accentPurple.withValues(alpha: 0.6),
      blurRadius: 128,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: AppColors.accentBlue.withValues(alpha: 0.8),
      blurRadius: 64,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    ),
  ];
}
