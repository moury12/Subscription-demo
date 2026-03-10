import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

class StepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final bool showSkip;
  final VoidCallback? onSkip;

  const StepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    this.showSkip = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          if (currentStep > 0)
            Text(
              'Step $currentStep of $totalSteps',
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            ),
          if (showSkip)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }
}
