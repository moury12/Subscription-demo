import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'add_meal_screen.dart';
import '../widgets/meal_section_card.dart';
import '../widgets/nutrition_summary_card.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.nutritionSectionGap),
              const NutritionSummaryCard(
                consumed: 164,
                remaining: 0,
                protein: 6,
                carbs: 6,
                fat: 14,
              ),
              const SizedBox(height: AppSpacing.nutritionSectionGap),
              MealSectionCard(
                title: 'breakfast',
                icon: Icons.free_breakfast,
                caloriesLabel: '164 cal',
                mealName: 'Almonds (28g)',
                mealDetail: '164 cal • P: 6g • C: 6g • F: 14g',
                onDelete: () {},
              ),
              const SizedBox(height: AppSpacing.nutritionSectionGap),
              MealSectionCard(
                title: 'lunch',
                icon: Icons.wb_sunny_outlined,
                emptyLabel: 'No meals logged yet',
                onAdd: () => _openAddMeal(context),
              ),
              const SizedBox(height: AppSpacing.nutritionSectionGap),
              MealSectionCard(
                title: 'dinner',
                icon: Icons.nights_stay_outlined,
                emptyLabel: 'No meals logged yet',
                onAdd: () => _openAddMeal(context),
              ),
              const SizedBox(height: AppSpacing.nutritionSectionGap),
              MealSectionCard(
                title: 'snack',
                icon: Icons.cookie_outlined,
                emptyLabel: 'No meals logged yet',
                onAdd: () => _openAddMeal(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddMeal(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddMealScreen()));
  }
}
