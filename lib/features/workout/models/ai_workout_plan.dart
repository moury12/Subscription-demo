class AiWorkoutExercise {
  final int stepNumber;
  final String exerciseName;
  final String shortInstruction;
  final List<String> detailedSteps;
  final int repsCount;
  final String ctaLabel;
  final String completionRule;

  AiWorkoutExercise({
    required this.stepNumber,
    required this.exerciseName,
    required this.shortInstruction,
    required this.detailedSteps,
    required this.repsCount,
    required this.ctaLabel,
    required this.completionRule,
  });

  factory AiWorkoutExercise.fromJson(Map<String, dynamic> json) {
    return AiWorkoutExercise(
      stepNumber: json['step_number'] ?? 0,
      exerciseName: json['exercise_name'] ?? '',
      shortInstruction: json['short_instruction'] ?? '',
      detailedSteps: List<String>.from(json['detailed_steps'] ?? []),
      repsCount: json['reps_count'] ?? 0,
      ctaLabel: json['cta_label'] ?? '',
      completionRule: json['completion_rule'] ?? '',
    );
  }
}

class AiWorkoutDay {
  final String day;
  final String title;
  final bool isRestDay;
  final List<AiWorkoutExercise> exercises;

  AiWorkoutDay({
    required this.day,
    required this.title,
    required this.isRestDay,
    required this.exercises,
  });

  factory AiWorkoutDay.fromJson(Map<String, dynamic> json) {
    return AiWorkoutDay(
      day: json['day'] ?? '',
      title: json['title'] ?? '',
      isRestDay: json['isRestDay'] ?? false,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => AiWorkoutExercise.fromJson(e))
          .toList(),
    );
  }
}

class NutritionalTargets {
  final int dailyCalories;
  final int dailyProtein;
  final int dailyCarbs;
  final int dailyFat;

  NutritionalTargets({
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });

  factory NutritionalTargets.fromJson(Map<String, dynamic> json) {
    return NutritionalTargets(
      dailyCalories: (json['dailyCalories'] as num?)?.toInt() ?? 2000,
      dailyProtein: (json['dailyProtein'] as num?)?.toInt() ?? 150,
      dailyCarbs: (json['dailyCarbs'] as num?)?.toInt() ?? 225,
      dailyFat: (json['dailyFat'] as num?)?.toInt() ?? 65,
    );
  }
}

class AiWeeklyWorkoutPlan {
  final String planTitle;
  final int weekNumber;
  final List<AiWorkoutDay> days;
  final NutritionalTargets? nutritionalTargets;

  AiWeeklyWorkoutPlan({
    required this.planTitle,
    required this.weekNumber,
    required this.days,
    this.nutritionalTargets,
  });

  factory AiWeeklyWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return AiWeeklyWorkoutPlan(
      planTitle: json['planTitle'] ?? '',
      weekNumber: json['weekNumber'] ?? 1,
      days: (json['days'] as List? ?? [])
          .map((d) => AiWorkoutDay.fromJson(d))
          .toList(),
      nutritionalTargets: json['nutritionalTargets'] != null
          ? NutritionalTargets.fromJson(json['nutritionalTargets'])
          : null,
    );
  }
}
