import 'package:flutter/material.dart';
import '../models/ai_workout_plan.dart';
import '../../../core/services/log_service.dart';
import '../../../core/services/reminder_scheduler.dart';

class WorkoutController extends ChangeNotifier {
  static final WorkoutController _instance = WorkoutController._internal();
  factory WorkoutController() => _instance;
  WorkoutController._internal();

  AiWorkoutDay? _activeWorkout;
  int _currentExerciseIndex = 0;
  bool _isPaused = false;
  final Set<String> _completedWorkoutTitles = {};
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
      final title = _activeWorkout!.title;
      _completedWorkoutTitles.add(title);
      final todayKey = _dayKey(DateTime.now());
      _completedWorkoutsByDay[todayKey] =
          (_completedWorkoutsByDay[todayKey] ?? 0) + 1;
      
      LogService().saveWorkoutLog({
        'date': DateTime.now().toIso8601String(),
        'workoutTitle': title,
        'exercises': _activeWorkout!.exercises.map((e) => {
          'name': e.name,
          'sets': e.sets,
          'reps': e.reps,
          'completed': true
        }).toList(),
        'durationMinutes': 0,
        'notes': title,
      });
    }
    _activeWorkout = null;
    _currentExerciseIndex = 0;
    _isPaused = false;
    ReminderScheduler().onWorkoutLogged();
    notifyListeners();
  }

  /// Load completed workout logs from the backend database to restore state
  Future<void> loadFromDatabase() async {
    final logs = await LogService().getWorkoutLogs();
    _completedWorkoutTitles.clear();
    _completedWorkoutsByDay.clear();

    for (final log in logs) {
      final dateStr = log['date'] as String?;
      if (dateStr != null) {
        final logDate = DateTime.tryParse(dateStr);
        if (logDate != null) {
          final dayKey = _dayKey(logDate);
          _completedWorkoutsByDay[dayKey] =
              (_completedWorkoutsByDay[dayKey] ?? 0) + 1;
        }
      }
      final title = log['workoutTitle'] as String? ?? log['notes'] as String? ?? '';
      if (title.isNotEmpty) {
        _completedWorkoutTitles.add(title);
      }
    }
    notifyListeners();
  }

  void clearAll() {
    _completedWorkoutTitles.clear();
    _completedWorkoutsByDay.clear();
    _activeWorkout = null;
    _currentExerciseIndex = 0;
    _isPaused = false;
    notifyListeners();
  }

  String _dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
