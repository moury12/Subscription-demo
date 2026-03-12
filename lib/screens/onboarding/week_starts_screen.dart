import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/step_header.dart';

class WeekStartsScreen extends StatefulWidget {
  final String selectedDay;
  final Function(String) onContinue;
  final VoidCallback onBack;

  const WeekStartsScreen({
    super.key,
    required this.selectedDay,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<WeekStartsScreen> createState() => _WeekStartsScreenState();
}

class _WeekStartsScreenState extends State<WeekStartsScreen> {
  late String _tempSelectedDay;
  final List<String> _days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    _tempSelectedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    final int initialIndex = _days.indexOf(_tempSelectedDay);

    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 6,
              totalSteps: 9,
              onBack: widget.onBack,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Week Starts From', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Select the day your week begins.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Center(
                      child: SizedBox(
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Selection indicator boundaries with glassmorphism feel
                            Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.symmetric(
                                  horizontal: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: initialIndex != -1 ? initialIndex : 2,
                              ),
                              itemExtent: 60,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _tempSelectedDay = _days[index];
                                });
                              },
                              children: _days.map((day) {
                                final isSelected = _tempSelectedDay == day;
                                return Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                                      fontSize: isSelected ? 28 : 22,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontFamily: 'Inter',
                                    ),
                                    child: Text(day),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    PrimaryGlowButton(
                      label: 'Continue',
                      onPressed: () => widget.onContinue(_tempSelectedDay),
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
