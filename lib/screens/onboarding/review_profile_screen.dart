import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../features/onboarding/models/onboarding_data.dart';

class ReviewProfileScreen extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onBack;
  final VoidCallback onGenerate;

  const ReviewProfileScreen({
    super.key,
    required this.data,
    required this.onBack,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 24),
                    const Text('Review Your Profile', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure everything looks good',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    _buildSummaryCard('Personal Info', '${data.age} years old • ${data.gender}'),
                    const SizedBox(height: 16),
                    _buildSummaryCard('Physical Stats', '${data.height} cm • ${data.currentWeight} kg'),
                    const SizedBox(height: 16),
                    _buildSummaryCard('Fitness Goal', '${data.goal}'),
                    const SizedBox(height: 16),
                    _buildSummaryCard('Activity Level', '${data.activityLevel}'),
                    const SizedBox(height: 16),
                    _buildSummaryCard('Timezone', '${data.timezone}'),
                    const SizedBox(height: 16),
                    _buildSummaryCard('Workout Schedule', '${data.workoutDays} days per week'),
                    const SizedBox(height: 16),
                    _buildSummaryCard('Dietary Preference', '${data.dietPreference}'),
                    const SizedBox(height: 16),
                    _buildSummaryCard('Target Weight', '${data.targetWeight} kg'),
                    const SizedBox(height: 48),
                    PrimaryGlowButton(
                      label: 'Generate My Plan',
                      onPressed: onGenerate,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
