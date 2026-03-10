import 'package:flutter/material.dart';
import '../models/food.dart';

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
