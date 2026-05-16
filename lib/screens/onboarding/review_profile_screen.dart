import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';
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
    final l10n = context.watch<LanguageProvider>();
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.getString('onboarding.review_your_profile'),
                        style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('onboarding.looks_good'),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSummaryCard(
                      l10n.getString('onboarding.personal_info'),
                      '${l10n.formatInteger(data.age ?? 0)} ${l10n.getString('onboarding.years_old')} • ${l10n.getString('onboarding.${data.gender?.toLowerCase()}')}',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      l10n.getString('onboarding.physical_stats'),
                      '${l10n.formatInteger((data.height ?? 0).toInt())} ${l10n.getString('onboarding.cm')} • ${l10n.formatWeight(data.currentWeight ?? 0)} ${l10n.getString('onboarding.kg')}',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(l10n.getString('onboarding.fitness_goal'),
                        l10n.getString('onboarding.${data.goal?.toLowerCase().replaceAll(' ', '_')}')),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      l10n.getString('onboarding.activity_level'),
                      l10n.getString('onboarding.${data.activityLevel?.toLowerCase().replaceAll(' ', '_')}'),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                        l10n.getString('onboarding.timezone'), '${data.timezone}'),
                    const SizedBox(height: 16),
                    _buildSummaryCard(l10n.getString('onboarding.week_starts'),
                        l10n.getString('onboarding.${data.weekStartDay.toLowerCase()}')),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      l10n.getString('onboarding.workout_schedule'),
                      '${l10n.formatInteger(data.workoutDays)} ${l10n.getString('onboarding.days_per_week')}',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      l10n.getString('onboarding.dietary_preference'),
                      l10n.getString('onboarding.${data.dietPreference?.toLowerCase()}'),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      l10n.getString('onboarding.target_weight'),
                      '${l10n.formatWeight(data.targetWeight ?? 0)} ${l10n.getString('onboarding.kg')}',
                    ),
                    const SizedBox(height: 48),
                    PrimaryGlowButton(
                      label: l10n.getString('onboarding.generate_plan'),
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
          Text(
            title,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
