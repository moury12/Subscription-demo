import 'package:flutter/foundation.dart';
import '../../../core/app_settings.dart';
import '../../nutrition/controllers/nutrition_controller.dart';
import '../models/home_dashboard_model.dart';

class HomeController extends ChangeNotifier {
  HomeController() {
    NutritionController().addListener(_onNutritionChanged);
  }

  void _onNutritionChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    NutritionController().removeListener(_onNutritionChanged);
    super.dispose();
  }

  HomeDashboardModel get model => HomeDashboardModel(
        userName: AppSettings().userName ?? 'User',
        streakDays: 0,
        consumedCalories: NutritionController().totalCalories.round(),
        targetCalories: AppSettings().targetCalories,
        workoutsCompleted: 0,
        dayStreak: 0,
      );
}
