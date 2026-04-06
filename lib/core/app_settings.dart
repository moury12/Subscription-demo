import '../features/workout/models/ai_workout_plan.dart';

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  AiWeeklyWorkoutPlan? currentPlan;
  String? userName = 'Nur Hasan Masum';
  int? age;
  String? gender;
  double? height;
  double? currentWeight;
  String? goal;
  String? activityLevel;
  int workoutDays = 3;
  String? dietPreference;
  double? targetWeight;
  String? timezone;
  String weekStartDay = 'Monday';
  int targetCalories = 2000;
  int targetProtein = 150;
  int targetCarbs = 200;
  int targetFat = 60;
}
