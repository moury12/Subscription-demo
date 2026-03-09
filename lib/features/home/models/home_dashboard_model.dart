class HomeDashboardModel {
  const HomeDashboardModel({
    required this.userName,
    required this.streakDays,
    required this.consumedCalories,
    required this.targetCalories,
    required this.workoutsCompleted,
    required this.dayStreak,
  });

  final String userName;
  final int streakDays;
  final int consumedCalories;
  final int targetCalories;
  final int workoutsCompleted;
  final int dayStreak;

  double get caloriesProgress {
    if (targetCalories == 0) return 0;
    return (consumedCalories / targetCalories).clamp(0, 1);
  }

  int get remainingCalories => targetCalories - consumedCalories;
}
