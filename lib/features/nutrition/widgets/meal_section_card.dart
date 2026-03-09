import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MealSectionCard extends StatelessWidget {
  const MealSectionCard({
    required this.title,
    required this.icon,
    this.caloriesLabel,
    this.mealName,
    this.mealDetail,
    this.emptyLabel,
    this.onAdd,
    this.onDelete,
    super.key,
  });

  final String title;
  final IconData icon;
  final String? caloriesLabel;
  final String? mealName;
  final String? mealDetail;
  final String? emptyLabel;
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;

  bool get isEmpty => mealName == null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 31.99,
              height: 31.99,
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color.fromRGBO(52, 211, 153, 0.5), blurRadius: 16)],
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 18),
            ),
            const SizedBox(width: AppSpacing.nutritionCardGap),
            Text(title, style: AppTextStyles.h3),
            const Spacer(),
            if (caloriesLabel != null)
              Text(caloriesLabel!, style: AppTextStyles.body14Soft),
          ],
        ),
        const SizedBox(height: AppSpacing.nutritionCardGap),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderSoft, width: 1.1),
          ),
          child: isEmpty ? _buildEmpty() : _buildFilled(),
        ),
      ],
    );
  }

  Widget _buildFilled() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mealName!, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(mealDetail!, style: AppTextStyles.body14Soft),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF87171), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17.1, 17.1, 17.1, 17.1),
      child: Column(
        children: [
          Text(emptyLabel ?? 'No meals logged yet', style: AppTextStyles.body14Soft),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onAdd,
            child: Text('+ Add $title', style: AppTextStyles.authAction.copyWith(color: AppColors.accentGreen)),
          ),
        ],
      ),
    );
  }
}
