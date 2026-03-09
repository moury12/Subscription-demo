import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/inputs/app_text_input.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Add meal')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutrition Information', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            const AppTextInput(hint: 'Meal Name', prefixIcon: Icon(Icons.restaurant, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            const AppTextInput(hint: 'Calories', prefixIcon: Icon(Icons.local_fire_department, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            const AppTextInput(hint: 'Protein (g)', prefixIcon: Icon(Icons.egg_alt_outlined, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            const AppTextInput(hint: 'Carbs (g)', prefixIcon: Icon(Icons.rice_bowl_outlined, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            const AppTextInput(hint: 'Fat (g)', prefixIcon: Icon(Icons.water_drop_outlined, color: AppColors.textSecondary)),
            const Spacer(),
            PrimaryGlowButton(label: 'Save Meal', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
