import 'package:flutter/material.dart';
import '../models/food.dart';
import '../../../core/services/log_service.dart';
import '../../../core/services/reminder_scheduler.dart';

class NutritionController extends ChangeNotifier {
  static final NutritionController _instance = NutritionController._internal();
  factory NutritionController() => _instance;
  NutritionController._internal();

  final List<LoggedMeal> _loggedMeals = [];

  List<LoggedMeal> get loggedMeals => _loggedMeals;

  void addMeal(String type, Food food, double multiplier) {
    _loggedMeals.add(LoggedMeal(
      type: type,
      food: food,
      multiplier: multiplier,
    ));
    
    LogService().saveMealLog({
      'mealType': type,
      'dishName': food.name,
      'totalCalories': food.calories * multiplier,
      'totalProtein': food.protein * multiplier,
      'totalCarbs': food.carbs * multiplier,
      'totalFat': food.fat * multiplier,
      'ingredients': []
    });

    ReminderScheduler().onMealLogged(type);
    notifyListeners();
  }

  void removeMeal(LoggedMeal meal) {
    _loggedMeals.remove(meal);
    notifyListeners();
  }

  /// Load today's meal logs from the backend database
  Future<void> loadFromDatabase() async {
    final logs = await LogService().getMealLogs();
    _loggedMeals.clear();

    final today = DateTime.now();
    for (final log in logs) {
      final dateStr = log['date'] as String?;
      if (dateStr != null) {
        final logDate = DateTime.tryParse(dateStr);
        if (logDate != null &&
            logDate.year == today.year &&
            logDate.month == today.month &&
            logDate.day == today.day) {
          _loggedMeals.add(LoggedMeal(
            type: log['mealType'] ?? 'Snack',
            food: Food(
              name: log['dishName'] ?? '',
              servingSize: '1 serving',
              calories: (log['totalCalories'] as num?)?.toDouble() ?? 0,
              protein: (log['totalProtein'] as num?)?.toDouble() ?? 0,
              carbs: (log['totalCarbs'] as num?)?.toDouble() ?? 0,
              fat: (log['totalFat'] as num?)?.toDouble() ?? 0,
            ),
            multiplier: 1.0,
          ));
        }
      }
    }
    notifyListeners();
  }

  void clearAll() {
    _loggedMeals.clear();
    notifyListeners();
  }

  double get totalCalories => _loggedMeals.fold(0, (sum, item) => sum + (item.food.calories * item.multiplier));
  double get totalProtein => _loggedMeals.fold(0, (sum, item) => sum + (item.food.protein * item.multiplier));
  double get totalCarbs => _loggedMeals.fold(0, (sum, item) => sum + (item.food.carbs * item.multiplier));
  double get totalFat => _loggedMeals.fold(0, (sum, item) => sum + (item.food.fat * item.multiplier));
}

class LoggedMeal {
  final String type;
  final Food food;
  final double multiplier;

  LoggedMeal({
    required this.type,
    required this.food,
    required this.multiplier,
  });
}
