import 'package:flutter/material.dart';
import '../models/ai_burn_model.dart';
import '../../../core/services/log_service.dart';

class BurnLog {
  final String activity;
  final String duration;
  final DateTime date;
  final double caloriesBurned;

  BurnLog({
    required this.activity,
    required this.duration,
    required this.date,
    required this.caloriesBurned,
  });
}

class BurnHistoryController extends ChangeNotifier {
  static final BurnHistoryController _instance = BurnHistoryController._internal();
  factory BurnHistoryController() => _instance;
  BurnHistoryController._internal();

  final List<BurnLog> _history = [];

  List<BurnLog> get history => List.unmodifiable(_history);

  double get totalBurnedToday => _history
      .where((l) => _isSameDay(l.date, DateTime.now()))
      .fold(0.0, (sum, l) => sum + l.caloriesBurned);

  int get activityCountToday => _history
      .where((l) => _isSameDay(l.date, DateTime.now()))
      .length;

  void addAnalysedResult(AiBurnAnalysisResult result) {
    for (var act in result.activities) {
      _history.insert(0, BurnLog(
        activity: act.activity,
        duration: act.duration,
        date: DateTime.now(),
        caloriesBurned: act.caloriesBurned,
      ));
    }
    
    LogService().saveBurnLog({
      'activityDescription': 'AI Burn Analysis',
      'totalCaloriesBurned': result.totalCaloriesBurned,
      'activities': result.activities.map((a) => {
        'activity': a.activity,
        'duration': a.duration,
        'caloriesBurned': a.caloriesBurned
      }).toList()
    });

    notifyListeners();
  }

  /// Load burn logs from the backend database
  Future<void> loadFromDatabase() async {
    final logs = await LogService().getBurnLogs();
    _history.clear();

    for (final log in logs) {
      final activities = log['activities'] as List<dynamic>? ?? [];
      final dateStr = log['date'] as String?;
      final logDate = dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();

      for (final act in activities) {
        _history.add(BurnLog(
          activity: act['activity'] ?? '',
          duration: act['duration'] ?? '',
          date: logDate ?? DateTime.now(),
          caloriesBurned: (act['caloriesBurned'] as num?)?.toDouble() ?? 0,
        ));
      }
    }
    notifyListeners();
  }

  void clearAll() {
    _history.clear();
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
