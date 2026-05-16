import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
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
      'titleKey': 'onboarding.sedentary',
      'subtitleKey': 'onboarding.little_exercise',
    },
    {
      'title': 'Lightly Active',
      'titleKey': 'onboarding.lightly_active',
      'subtitleKey': 'onboarding.exercise_1_3',
    },
    {
      'title': 'Moderately Active',
      'titleKey': 'onboarding.moderately_active',
      'subtitleKey': 'onboarding.exercise_3_5',
    },
    {
      'title': 'Very Active',
      'titleKey': 'onboarding.very_active',
      'subtitleKey': 'onboarding.exercise_6_7',
    },
    {
      'title': 'Extra Active',
      'titleKey': 'onboarding.extra_active',
      'subtitleKey': 'onboarding.intense_exercise_daily',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.activityLevel;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();
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
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.getString('onboarding.activity_level'),
                        style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('onboarding.how_active'),
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: List.generate(_levels.length, (index) {
                        final level = _levels[index];
                        final isSelected = _selectedLevel == level['title'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OptionCard(
                            title: l10n.getString(level['titleKey']!),
                            subtitle: l10n.getString(level['subtitleKey']!),
                            isSelected: isSelected,
                            onTap: () => setState(
                                () => _selectedLevel = level['title']!),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 48),
                    PrimaryGlowButton(
                      label: l10n.getString('onboarding.continue'),
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
