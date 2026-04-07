import 'package:flutter/material.dart';
import '../models/ai_workout_plan.dart';

class WorkoutController extends ChangeNotifier {
  static final WorkoutController _instance = WorkoutController._internal();
  factory WorkoutController() => _instance;
  WorkoutController._internal();

  AiWorkoutDay? _activeWorkout;
  int _currentExerciseIndex = 0;
  bool _isPaused = false;
  final Set<String> _completedWorkoutTitles = {}; // Track completed workouts by title
  final Map<String, int> _completedWorkoutsByDay = {};

  AiWorkoutDay? get activeWorkout => _activeWorkout;
  int get currentExerciseIndex => _currentExerciseIndex;
  bool get isPaused => _isPaused;
  int get completedCount => _completedWorkoutTitles.length;
  int get completedToday => _completedWorkoutsByDay[_dayKey(DateTime.now())] ?? 0;

  int get dayStreak {
    int streak = 0;
    DateTime cursor = DateTime.now();
    while ((_completedWorkoutsByDay[_dayKey(cursor)] ?? 0) > 0) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool isWorkoutCompleted(String title) => _completedWorkoutTitles.contains(title);

  void startWorkout(AiWorkoutDay workout) {
    _activeWorkout = workout;
    _currentExerciseIndex = 0;
    _isPaused = false;
    notifyListeners();
  }

  void pauseWorkout(int index) {
    _currentExerciseIndex = index;
    _isPaused = true;
    notifyListeners();
  }

  void resumeWorkout() {
    _isPaused = false;
    notifyListeners();
  }

  void updateProgress(int index) {
    _currentExerciseIndex = index;
    notifyListeners();
  }

  void finishWorkout() {
    if (_activeWorkout != null) {
      _completedWorkoutTitles.add(_activeWorkout!.title);
      final todayKey = _dayKey(DateTime.now());
      _completedWorkoutsByDay[todayKey] =
          (_completedWorkoutsByDay[todayKey] ?? 0) + 1;
    }
    _activeWorkout = null;
    _currentExerciseIndex = 0;
    _isPaused = false;
    notifyListeners();
  }

  String _dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
