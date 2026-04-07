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

  AiWorkoutDay? get activeWorkout => _activeWorkout;
  int get currentExerciseIndex => _currentExerciseIndex;
  bool get isPaused => _isPaused;
  int get completedCount => _completedWorkoutTitles.length;

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
    }
    _activeWorkout = null;
    _currentExerciseIndex = 0;
    _isPaused = false;
    notifyListeners();
  }
}
