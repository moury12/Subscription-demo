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

  final List<BurnLog> _history = [
    // Mock initial data
    BurnLog(
      activity: 'walking for 20 minutes', 
      duration: '20 min', 
      date: DateTime(2026, 3, 12, 12, 4), 
      caloriesBurned: 87.5,
    ),
  ];

  List<BurnLog> get history => List.unmodifiable(_history);

  double get totalBurnedToday => _history
      .where((l) => l.date.day == DateTime.now().day)
      .fold(0.0, (sum, l) => sum + l.caloriesBurned);

  int get activityCountToday => _history
      .where((l) => l.date.day == DateTime.now().day)
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
    
    // Sync to backend
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
}
