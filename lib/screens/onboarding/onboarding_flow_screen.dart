import 'package:flutter/material.dart';
import '../../features/onboarding/models/onboarding_data.dart';
import '../../features/main/screens/main_shell_screen.dart';
import 'welcome_screen.dart';
import 'age_gender_screen.dart';
import 'physical_stats_screen.dart';
import 'goal_screen.dart';
import 'activity_level_screen.dart';
import 'workout_schedule_screen.dart';
import 'diet_preference_screen.dart';
import 'timezone_screen.dart';
import 'target_weight_screen.dart';
import 'review_profile_screen.dart';
import 'creating_plan_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final OnboardingData _data = OnboardingData();

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page! > 0) {
          _previousPage();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WelcomeScreen(
              onStart: _nextPage,
              onSkip: _finish,
            ),
            AgeGenderScreen(
              age: _data.age ?? 0,
              gender: _data.gender ?? 'Male',
              onBack: _previousPage,
              onContinue: (age, gender) {
                setState(() {
                  _data.age = age;
                  _data.gender = gender;
                });
                _nextPage();
              },
            ),
            PhysicalStatsScreen(
              height: _data.height ?? 0,
              weight: _data.currentWeight ?? 0,
              onBack: _previousPage,
              onContinue: (h, w) {
                setState(() {
                  _data.height = h;
                  _data.currentWeight = w;
                });
                _nextPage();
              },
            ),
            GoalScreen(
              goal: _data.goal ?? 'Lose Weight',
              onBack: _previousPage,
              onContinue: (goal) {
                setState(() {
                  _data.goal = goal;
                });
                _nextPage();
              },
            ),
            ActivityLevelScreen(
              activityLevel: _data.activityLevel ?? 'Moderately Active',
              onBack: _previousPage,
              onContinue: (level) {
                setState(() {
                  _data.activityLevel = level;
                });
                _nextPage();
              },
            ),
            TimezoneScreen(
              selectedTimezone: _data.timezone,
              onBack: _previousPage,
              onContinue: (tz) {
                setState(() {
                  _data.timezone = tz;
                });
                _nextPage();
              },
            ),
            WorkoutScheduleScreen(
              daysPerWeek: _data.workoutDays,
              onBack: _previousPage,
              onContinue: (days) {
                setState(() {
                  _data.workoutDays = days;
                });
                _nextPage();
              },
            ),
            DietaryPreferenceScreen(
              diet: _data.dietPreference ?? 'Everything',
              onBack: _previousPage,
              onContinue: (diet) {
                setState(() {
                  _data.dietPreference = diet;
                });
                _nextPage();
              },
            ),
            TargetWeightScreen(
              currentWeight: _data.currentWeight ?? 70.0,
              targetWeight: _data.targetWeight ?? 0,
              onBack: _previousPage,
              onContinue: (tw) {
                setState(() {
                  _data.targetWeight = tw;
                });
                _nextPage();
              },
            ),
            ReviewProfileScreen(
              data: _data,
              onBack: _previousPage,
              onGenerate: _nextPage,
            ),
            CreatingPlanScreen(
              onFinish: _finish,
            ),
          ],
        ),
      ),
    );
  }
}
