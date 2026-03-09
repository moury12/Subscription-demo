import '../models/nutrition_model.dart';

class NutritionController {
  const NutritionController();

  NutritionModel get model => const NutritionModel(consumedCalories: 0, targetCalories: 0);
}
