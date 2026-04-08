class OnboardingData {
  String? name;
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
  String valueType = 'metric';

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'entryWeight': currentWeight, // Assuming entry weight is current weight at onboarding
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'goal': goal,
      'activityLevel': activityLevel,
      'timezone': timezone,
      'weekStart': weekStartDay,
      'dietaryPreference': dietPreference,
      'valueType': valueType,
      'workoutSchedule': {
        'daysPerWeek': workoutDays,
      },
      'hasCompletedOnboarding': true,
    };
  }
}
