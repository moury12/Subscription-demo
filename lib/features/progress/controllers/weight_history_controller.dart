import 'package:flutter/material.dart';
import '../../../core/services/log_service.dart';
import '../../../core/app_settings.dart';
import '../../profile/services/profile_service.dart';

class WeightEntry {
  final double weight;
  final double? previousWeight;
  final double? change;
  final DateTime date;
  final String? notes;

  WeightEntry({
    required this.weight,
    this.previousWeight,
    this.change,
    required this.date,
    this.notes,
  });
}

class WeightHistoryController extends ChangeNotifier {
  static final WeightHistoryController _instance =
      WeightHistoryController._internal();
  factory WeightHistoryController() => _instance;
  WeightHistoryController._internal();

  final List<WeightEntry> _history = [];

  List<WeightEntry> get history => List.unmodifiable(_history);

  double? get latestWeight => _history.isNotEmpty ? _history.first.weight : null;

  double get totalChange {
    if (_history.length < 2) return 0;
    return _history.first.weight - _history.last.weight;
  }

  Future<void> logWeight(double newWeight, {String? notes}) async {
    final settings = AppSettings();
    final previousWeight = settings.currentWeight;
    final change = previousWeight != null
        ? double.parse((newWeight - previousWeight).toStringAsFixed(1))
        : null;

    _history.insert(
      0,
      WeightEntry(
        weight: newWeight,
        previousWeight: previousWeight,
        change: change,
        date: DateTime.now(),
        notes: notes,
      ),
    );

    settings.currentWeight = newWeight;

    LogService().saveWeightLog({
      'weight': newWeight,
      if (notes != null) 'notes': notes,
    });

    ProfileService().updateProfile({
      'currentWeight': newWeight,
    });

    notifyListeners();
  }

  Future<void> updateEntryWeight(double entryWeight) async {
    AppSettings().entryWeight = entryWeight;
    ProfileService().updateProfile({
      'entryWeight': entryWeight,
    });
    notifyListeners();
  }

  Future<void> loadFromDatabase() async {
    final logs = await LogService().getWeightLogs();
    _history.clear();

    for (final log in logs) {
      final dateStr = log['date'] as String?;
      final logDate =
          dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();

      _history.add(WeightEntry(
        weight: (log['weight'] as num?)?.toDouble() ?? 0,
        previousWeight: (log['previousWeight'] as num?)?.toDouble(),
        change: (log['change'] as num?)?.toDouble(),
        date: logDate ?? DateTime.now(),
        notes: log['notes'] as String?,
      ));
    }

    if (_history.isNotEmpty) {
      AppSettings().currentWeight = _history.first.weight;
    }

    notifyListeners();
  }

  void clearAll() {
    _history.clear();
    notifyListeners();
  }
}
