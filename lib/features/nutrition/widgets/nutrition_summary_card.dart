import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({
    required this.consumed,
    required this.remaining,
    required this.protein,
    required this.carbs,
    required this.fat,
    super.key,
  });

  final int consumed;
  final int remaining;
  final int protein;
  final int carbs;
  final int fat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderSoft, width: 1.1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.nutritionCardPadding,
              AppSpacing.nutritionCardPadding,
              AppSpacing.nutritionCardPadding,
              1.1,
            ),
            child: SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today\'s Calories', style: AppTextStyles.h3),
                        Text('$consumed/', style: AppTextStyles.valueLarge),
                        Text('$remaining cal remaining', style: AppTextStyles.body14Soft),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 10,
                            valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(255, 255, 255, 0.1)),
                          ),
                        ),
                        const SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: 0,
                            strokeWidth: 10,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                          ),
                        ),
                        const Text('0%', style: AppTextStyles.valueMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderSoft, width: 1.1)),
            ),
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.nutritionMacroTopPad, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MacroColumn(value: '${protein}g', label: 'Protein', glow: const Color.fromRGBO(96, 165, 250, 1)),
                _MacroColumn(value: '${carbs}g', label: 'Carbs', glow: const Color.fromRGBO(251, 146, 60, 1)),
                _MacroColumn(value: '${fat}g', label: 'Fat', glow: const Color.fromRGBO(167, 139, 250, 1)),
              ],
            ),
          ),
          const SizedBox(height: 17.1),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  const _MacroColumn({
    required this.value,
    required this.label,
    required this.glow,
  });

  final String value;
  final String label;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.value20.copyWith(
            shadows: [Shadow(color: glow, blurRadius: 16)],
          ),
        ),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary90)),
        const Text('/g', style: AppTextStyles.caption70),
      ],
    );
  }
}
