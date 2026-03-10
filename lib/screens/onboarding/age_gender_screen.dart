import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/inputs/app_text_input.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/step_header.dart';

class AgeGenderScreen extends StatefulWidget {
  final int age;
  final String gender;
  final Function(int, String) onContinue;
  final VoidCallback onBack;

  const AgeGenderScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<AgeGenderScreen> createState() => _AgeGenderScreenState();
}

class _AgeGenderScreenState extends State<AgeGenderScreen> {
  late TextEditingController _ageController;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.age > 0 ? widget.age.toString() : '');
    _selectedGender = widget.gender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 1,
              totalSteps: 7,
              onBack: widget.onBack,
              showSkip: true,
              onSkip: () => widget.onContinue(25, 'Male'), // Default skip values
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tell us about yourself', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'This helps us personalize your experience',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 48),
                    const Text('Age', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    AppTextInput(
                      hint: 'Enter your age',
                      controller: _ageController,
                    ),
                    const SizedBox(height: 32),
                    const Text('Gender', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildGenderButton('Male', Icons.male),
                        const SizedBox(width: 12),
                        _buildGenderButton('Female', Icons.female),
                        const SizedBox(width: 12),
                        _buildGenderButton('Other', Icons.transgender),
                      ],
                    ),
                    const Spacer(),
                    PrimaryGlowButton(
                      label: 'Continue',
                      onPressed: () {
                        final age = int.tryParse(_ageController.text) ?? 25;
                        widget.onContinue(age, _selectedGender);
                      },
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

  Widget _buildGenderButton(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceRaised : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.brandPrimary : AppColors.inputBorder,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withAlpha(50),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                gender,
                style: AppTextStyles.label.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
