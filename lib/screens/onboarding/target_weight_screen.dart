import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/inputs/app_text_input.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/step_header.dart';

class TargetWeightScreen extends StatefulWidget {
  final double currentWeight;
  final double targetWeight;
  final Function(double) onContinue;
  final VoidCallback onBack;

  const TargetWeightScreen({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  late TextEditingController _targetWeightController;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController(
      text: widget.targetWeight > 0 ? widget.targetWeight.toString() : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 8,
              totalSteps: 8,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Weight', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      "What's your goal weight?",
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    const Text('Current Weight', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Text(
                        '${widget.currentWeight} kg',
                        style: AppTextStyles.inputText,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Target Weight (kg)', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    AppTextInput(
                      hint: 'Enter your target weight',
                      controller: _targetWeightController,
                    ),
                    const SizedBox(height: 64),
                    PrimaryGlowButton(
                      label: 'Continue',
                      onPressed: () {
                        final tw = double.tryParse(_targetWeightController.text) ?? widget.currentWeight;
                        widget.onContinue(tw);
                      },
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
