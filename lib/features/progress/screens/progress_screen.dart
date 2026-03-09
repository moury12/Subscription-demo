import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/cards/app_surface_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

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
              Text('Progress', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.md),
              const AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Workouts Completed', style: AppTextStyles.h3),
                    SizedBox(height: AppSpacing.xs),
                    Text('0', style: AppTextStyles.valueLarge),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Workout Consistency', style: AppTextStyles.h3),
                    SizedBox(height: AppSpacing.xs),
                    Text('No data available yet', style: AppTextStyles.label),
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
