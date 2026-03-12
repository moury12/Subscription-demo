import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/option_card.dart';
import '../../widgets/onboarding/step_header.dart';

class GoalScreen extends StatefulWidget {
  final String goal;
  final Function(String) onContinue;
  final VoidCallback onBack;

  const GoalScreen({
    super.key,
    required this.goal,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  late String _selectedGoal;

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Lose Weight',
      'icon': Icons.trending_down,
      'color': Colors.redAccent,
    },
    {
      'title': 'Gain Muscle',
      'icon': Icons.trending_up,
      'color': Colors.greenAccent,
    },
    {
      'title': 'Maintain Weight',
      'icon': Icons.sync,
      'color': Colors.blueAccent,
    },
    {
      'title': 'Improve Endurance',
      'icon': Icons.bolt,
      'color': Colors.purpleAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.goal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 3,
              totalSteps: 9,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("What's your goal?", style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your primary fitness objective',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: List.generate(_goals.length, (index) {
                        final goal = _goals[index];
                        final isSelected = _selectedGoal == goal['title'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OptionCard(
                            title: goal['title'],
                            icon: Icon(
                              goal['icon'],
                              color: isSelected ? Colors.white : goal['color'],
                              size: 20,
                            ),
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedGoal = goal['title']),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 48),
                    PrimaryGlowButton(
                      label: 'Continue',
                      onPressed: () => widget.onContinue(_selectedGoal),
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
