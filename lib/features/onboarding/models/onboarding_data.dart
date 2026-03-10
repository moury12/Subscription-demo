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

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'height': height,
      'currentWeight': currentWeight,
      'goal': goal,
      'activityLevel': activityLevel,
      'workoutDays': workoutDays,
      'dietPreference': dietPreference,
      'targetWeight': targetWeight,
      'timezone': timezone,
    };
  }
}
