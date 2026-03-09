import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/workout_plan_card.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workout Schedule', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text('Choose your plan and keep consistent', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary90)),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  children: [
                    const WorkoutPlanCard(title: 'Beginner Plan', subtitle: 'Exercise 1-3 days/week', icon: Icons.self_improvement),
                    const SizedBox(height: AppSpacing.sm),
                    const WorkoutPlanCard(title: 'Intermediate Plan', subtitle: 'Exercise 3-5 days/week', icon: Icons.fitness_center),
                    const SizedBox(height: AppSpacing.sm),
                    const WorkoutPlanCard(title: 'Advanced Plan', subtitle: 'Exercise 6-7 days/week', icon: Icons.local_fire_department),
                    const SizedBox(height: AppSpacing.sm),
                    const WorkoutPlanCard(title: 'Today\'s Workout', subtitle: 'Exercise 1 of 5', icon: Icons.timer_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
