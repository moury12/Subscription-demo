import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
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
    final l10n = context.watch<LanguageProvider>();
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 9,
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
                    Text(l10n.getString('onboarding.target_weight'),
                        style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('onboarding.goal_weight'),
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Text(l10n.getString('onboarding.current_weight'),
                        style: AppTextStyles.labelMedium),
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
                        '${l10n.formatWeight(widget.currentWeight)} ${l10n.getString('onboarding.kg')}',
                        style: AppTextStyles.inputText,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                        '${l10n.getString('onboarding.target_weight')} (${l10n.getString('onboarding.kg')})',
                        style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    AppTextInput(
                      hint: l10n.getString('onboarding.enter_target_weight'),
                      controller: _targetWeightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 64),
                    PrimaryGlowButton(
                      label: l10n.getString('onboarding.continue'),
                      onPressed: () {
                        final tw = double.tryParse(_targetWeightController.text) ??
                            widget.currentWeight;
                        widget.onContinue(tw);
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
}

