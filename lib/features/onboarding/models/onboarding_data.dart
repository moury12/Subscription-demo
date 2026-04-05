class OnboardingData {
  int? age;
  String? gender;
  double? height; // in cm
  double? currentWeight; // in kg
  String? goal;
  String? activityLevel;
  int workoutDays = 3;
  String? dietPreference;
  double? targetWeight;
  String? timezone;
  String weekStartDay = 'Monday';

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'height': '${height?.toInt() ?? 0} cm',
      'weight': '${currentWeight?.toInt() ?? 0} kg',
      'targetWeight': '${targetWeight?.toInt() ?? 0} kg',
      'goal': goal,
      'activityLevel': activityLevel,
      'workoutDaysPerWeek': workoutDays,
      'dietaryPreference': dietPreference,
      'timezone': timezone,
      'weekStartDay': weekStartDay,
    };
  }
}
