import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../core/app_settings.dart';
import '../../features/onboarding/models/onboarding_data.dart';
import '../../features/workout/controllers/ai_workout_service.dart';

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
  final List<String> _steps = [
    'Analyzing your profile',
    'Generating personalized workout routine',
    'Optimizing exercises for your goal',
    'Finalizing your weekly plan',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate plan. Using default template.')),
        );
      } else {
        AppSettings().currentPlan = plan;
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
                const Text(
                  'Creating Your Plan',
                  style: AppTextStyles.splashTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Our AI is personalizing your workout and nutrition plan...',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                Column(
                  children: List.generate(_steps.length, (index) {
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
                          Text(
                            _steps[index],
                            style: AppTextStyles.body.copyWith(
                              color: isCompleted ? Colors.white : AppColors.textSecondary,
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
