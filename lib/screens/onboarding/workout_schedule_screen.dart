import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/step_header.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  final int daysPerWeek;
  final Function(int) onContinue;
  final VoidCallback onBack;

  const WorkoutScheduleScreen({
    super.key,
    required this.daysPerWeek,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> {
  late double _days;

  @override
  void initState() {
    super.initState();
    _days = widget.daysPerWeek.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 7,
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
                    Text(l10n.getString('onboarding.workout_schedule'),
                        style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('onboarding.days_commit'),
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            l10n.formatInteger(_days.round()),
                            style: AppTextStyles.splashTitle.copyWith(
                              fontSize: 64,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                          Text(
                            l10n.getString('onboarding.days_per_week'),
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.brandPrimary,
                        inactiveTrackColor: AppColors.surfaceRaised,
                        thumbColor: Colors.white,
                        overlayColor: AppColors.brandPrimary.withAlpha(30),
                        valueIndicatorColor: AppColors.brandPrimary,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                        tickMarkShape: const RoundSliderTickMarkShape(),
                        activeTickMarkColor: Colors.white.withAlpha(100),
                        inactiveTickMarkColor: Colors.white.withAlpha(50),
                      ),
                      child: Slider(
                        value: _days,
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: _days.round().toString(),
                        onChanged: (value) => setState(() => _days = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          7,
                          (index) => Text(
                            l10n.formatInteger(index + 1),
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withAlpha(10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.brandPrimary.withAlpha(20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: AppColors.brandPrimary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.getString('onboarding.realistic_goal'),
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textPrimary70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryGlowButton(
                      label: l10n.getString('onboarding.continue'),
                      onPressed: () => widget.onContinue(_days.round()),
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

