import 'package:flutter/foundation.dart';
import '../../../core/app_settings.dart';
import '../../nutrition/controllers/nutrition_controller.dart';
import '../../workout/controllers/workout_controller.dart';
import '../models/home_dashboard_model.dart';

class HomeController extends ChangeNotifier {
  HomeController() {
    NutritionController().addListener(_onNutritionChanged);
    WorkoutController().addListener(_onWorkoutChanged);
  }

  void _onNutritionChanged() {
    notifyListeners();
  }

  void _onWorkoutChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    NutritionController().removeListener(_onNutritionChanged);
    WorkoutController().removeListener(_onWorkoutChanged);
    super.dispose();
  }

  HomeDashboardModel get model => HomeDashboardModel(
        userName: AppSettings().userName ?? 'User',
        streakDays: WorkoutController().dayStreak,
        consumedCalories: NutritionController().totalCalories.round(),
        targetCalories: AppSettings().targetCalories,
        workoutsCompleted: WorkoutController().completedToday,
        dayStreak: WorkoutController().dayStreak,
      );
}
