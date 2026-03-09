import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Reusable pagination dots indicator
class PaginationDots extends StatelessWidget {
  final int totalDots;
  final int currentIndex;
  final double dotSize;
  final double gap;
  final Color activeColor;
  final Color inactiveColor;

  const PaginationDots({
    super.key,
    required this.totalDots,
    this.currentIndex = 0,
    this.dotSize = AppSpacing.splashDotSize,
    this.gap = AppSpacing.splashDotGap,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color.fromRGBO(255, 255, 255, 0.6),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index < totalDots - 1 ? gap : 0,
          ),
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: index == currentIndex ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
