import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/option_card.dart';
import '../../widgets/onboarding/step_header.dart';

class ActivityLevelScreen extends StatefulWidget {
  final String activityLevel;
  final Function(String) onContinue;
  final VoidCallback onBack;

  const ActivityLevelScreen({
    super.key,
    required this.activityLevel,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  late String _selectedLevel;

  final List<Map<String, String>> _levels = [
    {
      'title': 'Sedentary',
      'subtitle': 'Little to no exercise',
    },
    {
      'title': 'Lightly Active',
      'subtitle': 'Exercise 1-3 days/week',
    },
    {
      'title': 'Moderately Active',
      'subtitle': 'Exercise 3-5 days/week',
    },
    {
      'title': 'Very Active',
      'subtitle': 'Exercise 6-7 days/week',
    },
    {
      'title': 'Extra Active',
      'subtitle': 'Very intense exercise daily',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.activityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 4,
              totalSteps: 9,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Activity Level', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'How active are you currently?',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: List.generate(_levels.length, (index) {
                        final level = _levels[index];
                        final isSelected = _selectedLevel == level['title'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OptionCard(
                            title: level['title']!,
                            subtitle: level['subtitle']!,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedLevel = level['title']!),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 48),
                    PrimaryGlowButton(
                      label: 'Continue',
                      onPressed: () => widget.onContinue(_selectedLevel),
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
}
