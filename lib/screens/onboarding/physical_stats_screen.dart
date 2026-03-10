import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/inputs/app_text_input.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/step_header.dart';

class PhysicalStatsScreen extends StatefulWidget {
  final double height;
  final double weight;
  final Function(double, double) onContinue;
  final VoidCallback onBack;

  const PhysicalStatsScreen({
    super.key,
    required this.height,
    required this.weight,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<PhysicalStatsScreen> createState() => _PhysicalStatsScreenState();
}

class _PhysicalStatsScreenState extends State<PhysicalStatsScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  bool _isMetric = true;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.height > 0 ? widget.height.toString() : '');
    _weightController = TextEditingController(text: widget.weight > 0 ? widget.weight.toString() : '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 2,
              totalSteps: 7,
              onBack: widget.onBack,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Physical Stats', style: AppTextStyles.h1),
                              const SizedBox(height: 8),
                              Text(
                                'Help us calculate your calorie needs',
                                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 32),
                              // Metric/Imperial Toggle
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.inputBorder),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildUnitToggle('Metric', _isMetric, () => setState(() => _isMetric = true)),
                                    ),
                                    Expanded(
                                      child: _buildUnitToggle('Imperial', !_isMetric, () => setState(() => _isMetric = false)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text('Height (${_isMetric ? 'cm' : 'ft'})', style: AppTextStyles.labelMedium),
                              const SizedBox(height: 12),
                              AppTextInput(
                                hint: _isMetric ? 'e.g., 175' : 'e.g., 5.9',
                                controller: _heightController,
                              ),
                              const SizedBox(height: 24),
                              Text('Current Weight (${_isMetric ? 'kg' : 'lbs'})', style: AppTextStyles.labelMedium),
                              const SizedBox(height: 12),
                              AppTextInput(
                                hint: _isMetric ? 'e.g., 70' : 'e.g., 154',
                                controller: _weightController,
                              ),
                              const Spacer(),
                              const SizedBox(height: 24),
                              PrimaryGlowButton(
                                label: 'Continue',
                                onPressed: () {
                                  final h = double.tryParse(_heightController.text) ?? 170.0;
                                  final w = double.tryParse(_weightController.text) ?? 70.0;
                                  widget.onContinue(h, w);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
