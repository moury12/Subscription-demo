import '../features/workout/models/ai_workout_plan.dart';

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  AiWeeklyWorkoutPlan? currentPlan;
  String? userName;
  int? age;
  String? gender;
  double? height;
  double? currentWeight;
  /// Starting weight when the user began tracking (baseline for progress).
  double? entryWeight;
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

  void syncFromProfile(Map<String, dynamic> json) {
    userName = json['name'];
    age = json['age'];
    gender = json['gender'];
    height = (json['height'] as num?)?.toDouble();
    currentWeight = (json['currentWeight'] as num?)?.toDouble();
    entryWeight = (json['entryWeight'] as num?)?.toDouble();
    goal = json['goal'];
    activityLevel = json['activityLevel'];
    workoutDays = json['workoutSchedule']?['daysPerWeek'] ?? 3;
    dietPreference = json['dietaryPreference'];
    targetWeight = (json['targetWeight'] as num?)?.toDouble();
    timezone = json['timezone'];
    weekStartDay = json['weekStart'] ?? 'Monday';
  }
}
