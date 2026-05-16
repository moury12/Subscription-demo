import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../core/app_settings.dart';
import '../../features/onboarding/models/onboarding_data.dart';
import '../../features/workout/controllers/ai_workout_service.dart';
import '../../features/profile/services/profile_service.dart';

class CreatingPlanScreen extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onFinish;

  const CreatingPlanScreen({
    super.key, 
    required this.data,
    required this.onFinish,
  });

  @override
  State<CreatingPlanScreen> createState() => _CreatingPlanScreenState();
}

class _CreatingPlanScreenState extends State<CreatingPlanScreen> {
  int _completedSteps = 0;
  final List<String> _stepKeys = [
    'onboarding.step_analyzing_profile',
    'onboarding.step_generating_routine',
    'onboarding.step_optimizing_exercises',
    'onboarding.step_finalizing_plan',
  ];
  
  final AiWorkoutService _workoutService = AiWorkoutService();

  @override
  void initState() {
    super.initState();
    _generatePlan();
  }

  void _generatePlan() async {
    // Phase 1: Wait 1s and set step 1
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _completedSteps = 1);

    // Phase 2: Call AI API and set step 2
    final plan = await _workoutService.generateMyPlan(widget.data.toJson());
    if (mounted) setState(() => _completedSteps = 2);

    // Phase 3 & 4: Fake delay for smooth UI
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _completedSteps = 3);
    
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _completedSteps = 4);

    // Done
    if (mounted) {
      if (plan == null) {
        final l10n = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.getString('common.error'))), // "Error" text localized
        );
      } else {
        AppSettings().addWorkoutPlan(plan);
        if (plan.nutritionalTargets != null) {
          AppSettings().targetCalories = plan.nutritionalTargets!.dailyCalories;
          AppSettings().targetProtein = plan.nutritionalTargets!.dailyProtein;
          AppSettings().targetCarbs = plan.nutritionalTargets!.dailyCarbs;
          AppSettings().targetFat = plan.nutritionalTargets!.dailyFat;

          // Persist nutritional targets to user profile
          ProfileService().updateProfile({
            'nutritionalTargets': {
              'dailyCalories': plan.nutritionalTargets!.dailyCalories,
              'dailyProtein': plan.nutritionalTargets!.dailyProtein,
              'dailyCarbs': plan.nutritionalTargets!.dailyCarbs,
              'dailyFat': plan.nutritionalTargets!.dailyFat,
            }
          });
        }
      }
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceRaised,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPrimary.withAlpha(50),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 48),
                Text(
                  context.read<LanguageProvider>().getString('onboarding.creating_your_plan'),
                  style: AppTextStyles.splashTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  context.read<LanguageProvider>().getString('onboarding.personalized_plan_desc'),
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                Column(
                  children: List.generate(_stepKeys.length, (index) {
                    final isCompleted = index < _completedSteps;
                    final isCurrent = index == _completedSteps;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          if (isCompleted)
                            const Icon(Icons.check_circle, color: AppColors.brandPrimary, size: 20)
                          else if (isCurrent)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          else
                            const Icon(Icons.circle_outlined, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              context.read<LanguageProvider>().getString(_stepKeys[index]),
                              style: AppTextStyles.body.copyWith(
                                color: isCompleted ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
