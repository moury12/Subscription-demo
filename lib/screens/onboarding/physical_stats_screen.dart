import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/inputs/app_text_input.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/step_header.dart';

class PhysicalStatsScreen extends StatefulWidget {
  final double height;
  final double weight;
  final String valueType;
  final Function(double height, double weight, String valueType) onContinue;
  final VoidCallback onBack;

  const PhysicalStatsScreen({
    super.key,
    required this.height,
    required this.weight,
    this.valueType = 'metric',
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<PhysicalStatsScreen> createState() => _PhysicalStatsScreenState();
}

class _PhysicalStatsScreenState extends State<PhysicalStatsScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late bool _isMetric;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.valueType.toLowerCase() != 'imperial';
    _heightController = TextEditingController(
        text: widget.height > 0
            ? (_isMetric ? widget.height.toInt().toString() : widget.height.toString())
            : '');
    _weightController = TextEditingController(
        text: widget.weight > 0 ? widget.weight.toString() : '');
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _switchUnit(bool toMetric) {
    if (_isMetric == toMetric) return;

    final currentH = double.tryParse(_heightController.text);
    final currentW = double.tryParse(_weightController.text);

    setState(() {
      _isMetric = toMetric;

      if (toMetric) {
        // Imperial -> Metric (ft -> cm, lbs -> kg)
        if (currentH != null && currentH > 0) {
          final cm = (currentH * 30.48).round();
          _heightController.text = cm.toString();
        }
        if (currentW != null && currentW > 0) {
          final kg = double.parse((currentW / 2.20462).toStringAsFixed(1));
          _weightController.text = kg.toString();
        }
      } else {
        // Metric -> Imperial (cm -> ft, kg -> lbs)
        if (currentH != null && currentH > 0) {
          final ft = double.parse((currentH / 30.48).toStringAsFixed(1));
          _heightController.text = ft.toString();
        }
        if (currentW != null && currentW > 0) {
          final lbs = double.parse((currentW * 2.20462).toStringAsFixed(1));
          _weightController.text = lbs.toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 2,
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
                    Text(l10n.getString('onboarding.physical_stats'),
                        style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('onboarding.calorie_needs'),
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
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
                            child: _buildUnitToggle(
                                l10n.getString('onboarding.metric'),
                                _isMetric,
                                () => _switchUnit(true)),
                          ),
                          Expanded(
                            child: _buildUnitToggle(
                                l10n.getString('onboarding.imperial'),
                                !_isMetric,
                                () => _switchUnit(false)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                        '${l10n.getString('onboarding.height')} (${_isMetric ? l10n.getString('onboarding.cm') : l10n.getString('onboarding.ft')})',
                        style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    AppTextInput(
                      hint: _isMetric ? 'e.g., 175' : 'e.g., 5.9',
                      controller: _heightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 24),
                    Text(
                        '${l10n.getString('onboarding.current_weight')} (${_isMetric ? l10n.getString('onboarding.kg') : l10n.getString('onboarding.lbs')})',
                        style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    AppTextInput(
                      hint: _isMetric ? 'e.g., 70' : 'e.g., 154',
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 64),
                    PrimaryGlowButton(
                      label: l10n.getString('onboarding.continue'),
                      onPressed: () {
                        final defaultH = _isMetric ? 170.0 : 5.6;
                        final defaultW = _isMetric ? 70.0 : 154.0;
                        final h =
                            double.tryParse(_heightController.text) ?? defaultH;
                        final w =
                            double.tryParse(_weightController.text) ?? defaultW;
                        widget.onContinue(h, w, _isMetric ? 'metric' : 'imperial');
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

