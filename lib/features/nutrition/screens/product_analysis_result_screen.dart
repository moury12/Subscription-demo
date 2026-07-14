import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/product_analysis.dart';
import '../models/food.dart';
import '../controllers/nutrition_controller.dart';
import '../widgets/meal_logging_options.dart';

class ProductAnalysisResultScreen extends StatelessWidget {
  const ProductAnalysisResultScreen({super.key, required this.result});

  final ProductAnalysisResult result;

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.accentGreen;
    if (score >= 60) return Colors.orange;
    return Colors.redAccent;
  }

  Color _getNovaColor(int level) {
    switch (level) {
      case 1:
        return AppColors.accentGreen;
      case 2:
        return Colors.blueAccent;
      case 3:
        return Colors.orange;
      case 4:
      default:
        return Colors.redAccent;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'safe':
        return AppColors.accentGreen;
      case 'warning':
        return Colors.orange;
      case 'danger':
      case 'critical':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'safe':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'danger':
      case 'critical':
      default:
        return Icons.cancel;
    }
  }

  void _logProductToDiary(BuildContext context) async {
    // Parse values from string facts to double for logging
    final double caloriesVal = double.tryParse(
          result.nutritionFacts.calories.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
    final double fatVal = double.tryParse(
          result.nutritionFacts.totalFat.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
    final double carbsVal = double.tryParse(
          result.nutritionFacts.carbs?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
        ) ??
        0.0;
    final double proteinVal = double.tryParse(
          result.nutritionFacts.protein?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
        ) ??
        0.0;

    final foodItem = Food(
      name: result.productName,
      servingSize: result.subtext,
      calories: caloriesVal,
      protein: proteinVal,
      carbs: carbsVal,
      fat: fatVal,
    );

    // Show meal type selection dialog
    final String? selectedMeal = await MealLoggingOptions.showMealTypeSelector(context);
    if (selectedMeal == null) return; // User cancelled

    // Add to NutritionController
    NutritionController().addMeal(selectedMeal, foodItem, 1.0);

    if (!context.mounted) return;
    final l10n = Provider.of<LanguageProvider>(context, listen: false);
    // Localize meal type for display in snackbar
    final String mealDisplayStr = {
      'Breakfast': l10n.getString('nutrition.breakfast'),
      'Lunch': l10n.getString('nutrition.lunch'),
      'Dinner': l10n.getString('nutrition.dinner'),
      'Snack': l10n.getString('nutrition.snacks'),
    }[selectedMeal] ?? selectedMeal;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${result.productName}" added to $mealDisplayStr log!'),
        backgroundColor: AppColors.accentGreen,
      ),
    );

    // Pop back to home / dashboard
    Navigator.of(context).popUntil((route) => route.settings.name == '/main' || route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(result.qualityScore);
    final novaColor = _getNovaColor(result.novaScale);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Product Quality Analysis',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.brandPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Product Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF171F33),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: Colors.white24, size: 40),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandPrimary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      result.category,
                                      style: const TextStyle(
                                        color: AppColors.brandPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result.productName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    result.subtext,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Bento Grid Score Cards
                        Row(
                          children: [
                            // Quality Score Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF171F33),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: scoreColor.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scoreColor.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'QUALITY SCORE',
                                      style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          result.qualityScore.toInt().toString(),
                                          style: TextStyle(color: scoreColor, fontSize: 32, fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          '/100',
                                          style: TextStyle(color: Colors.white30, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      result.qualityRating,
                                      style: TextStyle(color: scoreColor, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // NOVA Scale Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF171F33),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'NOVA SCALE',
                                      style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: novaColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: novaColor.withOpacity(0.3), blurRadius: 10),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          result.novaScale.toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      result.novaRating,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: novaColor, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Nutrition Facts Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nutrition Facts',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Per serving',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildNutritionRow('Calories', result.nutritionFacts.calories),
                        _buildNutritionRow('Total Fat', result.nutritionFacts.totalFat),
                        if (result.nutritionFacts.saturatedFat != null)
                          _buildNutritionRow('Saturated Fat', result.nutritionFacts.saturatedFat!),
                        _buildNutritionRow('Sodium', result.nutritionFacts.sodium),
                        if (result.nutritionFacts.carbs != null)
                          _buildNutritionRow('Total Carbohydrates', result.nutritionFacts.carbs!),
                        if (result.nutritionFacts.sugar != null)
                          _buildNutritionRow('Total Sugars', result.nutritionFacts.sugar!),
                        if (result.nutritionFacts.protein != null)
                          _buildNutritionRow('Protein', result.nutritionFacts.protein!),
                        
                        // Extra vitamins / minerals
                        ...result.nutritionFacts.additionalVitamins.map(
                          (v) => _buildNutritionRow(
                            v.name,
                            v.value,
                            valueColor: v.isHealthy ? AppColors.accentGreen : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Sourcing & Ingredients Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Source & Ingredients',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: result.ingredients.map(
                            (ing) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171F33),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                ing,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ),
                          ).toList(),
                        ),
                        
                        if (result.additivesAlert.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.brandPrimary.withOpacity(0.05),
                              border: Border.all(color: AppColors.brandPrimary.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, color: AppColors.brandPrimary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    result.additivesAlert,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Allergens Alert (If present)
                  if (result.allergens.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Allergens Detected',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: result.allergens.map(
                              (alg) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  alg,
                                  style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 4. Purity Check (Contaminants) Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Purity Check',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...result.contaminants.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(c.status),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.value,
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  _getStatusIcon(c.status),
                                  color: _getStatusColor(c.status),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 5. Floating Bottom Log Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFF0B1326)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4],
                ),
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 12,
                    shadowColor: AppColors.brandPrimary.withOpacity(0.5),
                  ),
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  label: const Text(
                    'Add to Daily Log',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _logProductToDiary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, {Color valueColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
