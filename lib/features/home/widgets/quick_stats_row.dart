import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/language_provider.dart';
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
    final l10n = context.watch<LanguageProvider>();
    return Row(
      children: [
        Expanded(
          child: MiniStatCard(
            value: l10n.formatInteger(workouts),
            label: l10n.getString('home.workouts'),
            icon: Icons.fitness_center,
            iconColor: AppColors.accentPurple,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: MiniStatCard(
            value: l10n.formatInteger(streak),
            label: l10n.getString('home.day_streak'),
            icon: Icons.local_fire_department,
            iconColor: AppColors.accentGreen,
          ),
        ),
      ],
    );
  }
}
