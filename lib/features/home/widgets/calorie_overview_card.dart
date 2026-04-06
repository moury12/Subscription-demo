import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/cards/app_surface_card.dart';
import 'log_activity_options.dart';
import '../../nutrition/controllers/nutrition_controller.dart';
import '../../../core/app_settings.dart';

class CalorieOverviewCard extends StatelessWidget {
  const CalorieOverviewCard({
    required this.consumed,
    required this.target,
    required this.progress,
    super.key,
  });

  final int consumed;
  final int target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remaining = target - consumed;
    final progressPct = (progress * 100).round();

    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(17.1, 17.1, 17.1, 1.1),
      child: Column(
        children: [
          SizedBox(
            height: 111.83,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Logs', style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('$consumed/', style: AppTextStyles.valueLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('${remaining.clamp(0, target)} cal remaining', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('Start logging meals', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromRGBO(255, 255, 255, 0.1)),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accentGreen),
                        ),
                      ),
                      Text('$progressPct%', style: AppTextStyles.valueMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildMacroSummary(),
          const SizedBox(height: AppSpacing.md),
          PrimaryGlowButton(
            label: '+ Log Activity',
            height: 56,
            onPressed: () => LogActivityOptions.show(context),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMacroSummary() {
    final nutrition = NutritionController();
    final settings = AppSettings();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _macroItem('Protein', nutrition.totalProtein.round(),
            settings.targetProtein, Colors.green),
        _macroItem('Carbs', nutrition.totalCarbs.round(),
            settings.targetCarbs, Colors.orange),
        _macroItem('Fat', nutrition.totalFat.round(),
            settings.targetFat, Colors.blue),
      ],
    );
  }

  Widget _macroItem(String label, int current, int target, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$current/$target g',
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: (current / target).clamp(0.01, 1.0),
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 2.5,
          ),
        ),
      ],
    );
  }
}
