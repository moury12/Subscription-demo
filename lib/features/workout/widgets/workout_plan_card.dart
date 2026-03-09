import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/cards/app_surface_card.dart';

class WorkoutPlanCard extends StatelessWidget {
  const WorkoutPlanCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: AppColors.accentBlue, child: Icon(icon, color: AppColors.background)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textPrimary90),
        ],
      ),
    );
  }
}
