class AiWorkoutExercise {
  final String name;
  final int sets;
  final String reps;

  AiWorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
  });

  factory AiWorkoutExercise.fromJson(Map<String, dynamic> json) {
    return AiWorkoutExercise(
      name: json['name'] ?? '',
      sets: (json['sets'] as num?)?.toInt() ?? 0,
      reps: json['reps'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets,
    'reps': reps,
  };
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

  Map<String, dynamic> toJson() => {
    'day': day,
    'title': title,
    'isRestDay': isRestDay,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
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

  Map<String, dynamic> toJson() => {
    'dailyCalories': dailyCalories,
    'dailyProtein': dailyProtein,
    'dailyCarbs': dailyCarbs,
    'dailyFat': dailyFat,
  };
}

class AiWeeklyWorkoutPlan {
  final String planTitle;
  final int weekNumber;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AiWorkoutDay> days;
  final NutritionalTargets? nutritionalTargets;

  AiWeeklyWorkoutPlan({
    required this.planTitle,
    required this.weekNumber,
    this.startDate,
    this.endDate,
    required this.days,
    this.nutritionalTargets,
  });

  factory AiWeeklyWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return AiWeeklyWorkoutPlan(
      planTitle: json['planTitle'] ?? '',
      weekNumber: json['weekNumber'] ?? 1,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      days: (json['days'] as List? ?? [])
          .map((d) => AiWorkoutDay.fromJson(d))
          .toList(),
      nutritionalTargets: json['nutritionalTargets'] != null
          ? NutritionalTargets.fromJson(json['nutritionalTargets'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'planTitle': planTitle,
    'weekNumber': weekNumber,
    if (startDate != null) 'startDate': startDate!.toIso8601String(),
    if (endDate != null) 'endDate': endDate!.toIso8601String(),
    'days': days.map((d) => d.toJson()).toList(),
    if (nutritionalTargets != null) 'nutritionalTargets': nutritionalTargets!.toJson(),
  };

  bool coversDate(DateTime date) {
    if (startDate == null) return false;
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final end = endDate != null
        ? DateTime(endDate!.year, endDate!.month, endDate!.day)
        : start.add(const Duration(days: 6));
    final check = DateTime(date.year, date.month, date.day);
    return !check.isBefore(start) && !check.isAfter(end);
  }
}
