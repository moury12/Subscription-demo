import 'package:flutter/foundation.dart';
import '../app_settings.dart';
import '../services/log_service.dart';
import '../services/reminder_scheduler.dart';
import '../../features/workout/models/ai_workout_plan.dart';
import '../../features/nutrition/controllers/nutrition_controller.dart';
import '../../features/progress/controllers/burn_history_controller.dart';
import '../../features/progress/controllers/weight_history_controller.dart';
import '../../features/workout/controllers/workout_controller.dart';

/// Loads all persisted user data from the backend after login or app restart.
class UserDataSync {
  static Future<void> loadAll() async {
    await Future.wait([
      _loadWorkoutPlans(),
      NutritionController().loadFromDatabase(),
      BurnHistoryController().loadFromDatabase(),
      WorkoutController().loadFromDatabase(),
      WeightHistoryController().loadFromDatabase(),
    ]);
    debugPrint('[SYNC] All user data loaded from database');

    // Schedule notifications based on today's existing logs
    ReminderScheduler().scheduleTodayNotifications();
  }

  static Future<void> _loadWorkoutPlans() async {
    final plans = await LogService().getWorkoutPlans();
    final settings = AppSettings();
    settings.clearWorkoutPlans();

    for (final planJson in plans) {
      try {
        final plan = AiWeeklyWorkoutPlan.fromJson(planJson);
        settings.addWorkoutPlan(plan);
      } catch (e) {
        debugPrint('[SYNC] Skipping invalid workout plan: $e');
      }
    }

    // If the latest plan has nutritional targets, apply them
    if (settings.workoutPlans.isNotEmpty) {
      final latest = settings.workoutPlans.first;
      if (latest.nutritionalTargets != null) {
        settings.targetCalories = latest.nutritionalTargets!.dailyCalories;
        settings.targetProtein = latest.nutritionalTargets!.dailyProtein;
        settings.targetCarbs = latest.nutritionalTargets!.dailyCarbs;
        settings.targetFat = latest.nutritionalTargets!.dailyFat;
      }
    }
  }

  static void clearAll() {
    AppSettings().clearWorkoutPlans();
    NutritionController().clearAll();
    BurnHistoryController().clearAll();
    WorkoutController().clearAll();
    WeightHistoryController().clearAll();
  }
}
