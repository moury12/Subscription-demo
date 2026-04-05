class AiWorkoutExercise {
  final String name;
  final int sets;
  final String reps;
  final String? duration;
  final String? notes;

  AiWorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.duration,
    this.notes,
  });

  factory AiWorkoutExercise.fromJson(Map<String, dynamic> json) {
    return AiWorkoutExercise(
      name: json['name'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? '',
      duration: json['duration'],
      notes: json['notes'],
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

class AiWeeklyWorkoutPlan {
  final String planTitle;
  final int weekNumber;
  final List<AiWorkoutDay> days;

  AiWeeklyWorkoutPlan({
    required this.planTitle,
    required this.weekNumber,
    required this.days,
  });

  factory AiWeeklyWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return AiWeeklyWorkoutPlan(
      planTitle: json['planTitle'] ?? '',
      weekNumber: json['weekNumber'] ?? 1,
      days: (json['days'] as List? ?? [])
          .map((d) => AiWorkoutDay.fromJson(d))
          .toList(),
    );
  }
}
