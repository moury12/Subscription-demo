import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/diet_option_card.dart';
import '../../widgets/onboarding/step_header.dart';

class DietaryPreferenceScreen extends StatefulWidget {
  final String diet;
  final Function(String) onContinue;
  final VoidCallback onBack;

  const DietaryPreferenceScreen({
    super.key,
    required this.diet,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<DietaryPreferenceScreen> createState() => _DietaryPreferenceScreenState();
}

class _DietaryPreferenceScreenState extends State<DietaryPreferenceScreen> {
  late String _selectedDiet;

  final List<Map<String, String>> _diets = [
    {'title': 'Everything', 'emoji': '🍽️'},
    {'title': 'Vegetarian', 'emoji': '🥗'},
    {'title': 'Vegan', 'emoji': '🌱'},
    {'title': 'Pescatarian', 'emoji': '🐟'},
    {'title': 'Keto', 'emoji': '🥑'},
    {'title': 'Paleo', 'emoji': '🥩'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDiet = widget.diet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 8,
              totalSteps: 9,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dietary Preference', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Select your eating style for personalized nutrition',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _diets.length,
                      itemBuilder: (context, index) {
                        final diet = _diets[index];
                        return DietOptionCard(
                          title: diet['title']!,
                          iconAsset: '',
                          emoji: diet['emoji'],
                          isSelected: _selectedDiet == diet['title'],
                          onTap: () => setState(() => _selectedDiet = diet['title']!),
                        );
                      },
                    ),
                    const SizedBox(height: 64),
                    PrimaryGlowButton(
                      label: 'Continue',
                      onPressed: () => widget.onContinue(_selectedDiet),
                    ),
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
