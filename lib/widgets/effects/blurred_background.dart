import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable blurred background effect with positioned colored circles
class BlurredBackground extends StatelessWidget {
  final List<BlurredCircle> circles;

  const BlurredBackground({
    super.key,
    required this.circles,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: circles.map((circle) {
        return Positioned(
          left: circle.x,
          top: circle.y,
          child: Container(
            width: circle.size,
            height: circle.size,
            decoration: BoxDecoration(
              color: circle.color.withValues(alpha: circle.opacity),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: circle.blurRadius,
                sigmaY: circle.blurRadius,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: circle.color.withValues(alpha: circle.opacity),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BlurredCircle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double opacity;
  final double blurRadius;

  const BlurredCircle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    this.opacity = 1.0,
    this.blurRadius = 128,
  });

  // Preset for onboarding screen
  static const List<BlurredCircle> onboardingCircles = [
    BlurredCircle(
      x: 98.31,
      y: 212.97,
      size: 384,
      color: AppColors.accentBlue,
      opacity: 0.497426,
      blurRadius: 128,
    ),
    BlurredCircle(
      x: -89.05,
      y: 254.91,
      size: 384,
      color: AppColors.accentPurple,
      opacity: 0.31587,
      blurRadius: 128,
    ),
  ];
}
