import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/cards/mini_stat_card.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    required this.workouts,
    required this.streak,
    super.key,
  });

  final int workouts;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MiniStatCard(
            value: workouts.toString(),
            label: 'Workouts',
            icon: Icons.fitness_center,
            iconColor: AppColors.accentPurple,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: MiniStatCard(
            value: streak.toString(),
            label: 'Day Streak',
            icon: Icons.local_fire_department,
            iconColor: AppColors.accentGreen,
          ),
        ),
      ],
    );
  }
}
