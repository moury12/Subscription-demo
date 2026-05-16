import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
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
    _ageController =
        TextEditingController(text: widget.age > 0 ? widget.age.toString() : '');
    _selectedGender = widget.gender;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 1,
              totalSteps: 9,
              onBack: widget.onBack,
              showSkip: true,
              onSkip: () => widget.onContinue(25, 'Male'), // Default skip values
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.getString('onboarding.tell_us_about_yourself'),
                        style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('onboarding.personalize_experience'),
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 48),
                    Text(l10n.getString('onboarding.age'),
                        style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    AppTextInput(
                      hint: l10n.getString('onboarding.enter_your_age'),
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    Text(l10n.getString('onboarding.gender'),
                        style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildGenderButton(
                            'Male', Icons.male, l10n.getString('onboarding.male')),
                        const SizedBox(width: 12),
                        _buildGenderButton('Female', Icons.female,
                            l10n.getString('onboarding.female')),
                        const SizedBox(width: 12),
                        _buildGenderButton('Other', Icons.transgender,
                            l10n.getString('onboarding.other')),
                      ],
                    ),
                    const SizedBox(height: 64),
                    PrimaryGlowButton(
                      label: l10n.getString('onboarding.continue'),
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

  Widget _buildGenderButton(String gender, IconData icon, String label) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandPrimary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.brandPrimary : AppColors.inputBorder,
              width: 2,
            ),
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
                label,
                style: AppTextStyles.label.copyWith(
                  color:
                      isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

