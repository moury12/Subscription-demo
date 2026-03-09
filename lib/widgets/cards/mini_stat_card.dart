import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_surface_card.dart';

class MiniStatCard extends StatelessWidget {
  const MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    super.key,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(17.1, 17.1, 17.1, 1.1),
      child: SizedBox(
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: iconColor.withValues(alpha: 0.6), blurRadius: 20),
                  BoxShadow(color: iconColor.withValues(alpha: 0.3), blurRadius: 40),
                ],
              ),
              child: Icon(icon, size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTextStyles.valueMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary90)),
          ],
        ),
      ),
    );
  }
}
