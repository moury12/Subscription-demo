import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../controllers/nutrition_controller.dart';
import '../models/food.dart';
import '../widgets/nutrition_green_app_bar.dart';

class AiFoodAnalysisResultScreen extends StatelessWidget {
  final String mealType;
  final AiFoodAnalysisResult analysisResult;

  const AiFoodAnalysisResultScreen({
    super.key, 
    required this.mealType,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: NutritionGreenAppBar(title: l10n.getString('ai_food.scanner_title')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(l10n),
            const SizedBox(height: 32),
            Text(
              l10n.getString('ai_food.identified_ingredients'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            ...analysisResult.ingredients.map((food) {
              final details = {
                l10n.getString('nutrition.protein'): '${l10n.formatInteger(food.protein.toInt())}g',
                l10n.getString('nutrition.carbs'): '${l10n.formatInteger(food.carbs.toInt())}g',
                l10n.getString('nutrition.fat'): '${l10n.formatInteger(food.fat.toInt())}g',
              };
              if (food.fiber != null) details['Fiber'] = '${l10n.formatInteger(food.fiber!.toInt())}g';
              if (food.sodium != null) details['Sodium'] = food.sodium!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildIngredientCard(food.name, '${l10n.formatInteger(food.calories.toInt())} kcal', details),
              );
            }).toList(),
            const SizedBox(height: 12),
            _buildAiInsights(l10n),
            const SizedBox(height: 32),
            _buildBottomButtons(context, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(LanguageProvider l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            analysisResult.dishName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(l10n.formatInteger(analysisResult.totalCalories.toInt()), l10n.getString('nutrition.calories')),
              _buildSummaryItem('${l10n.formatInteger(analysisResult.totalProtein.toInt())}g', l10n.getString('nutrition.protein')),
              _buildSummaryItem('${l10n.formatInteger(analysisResult.totalCarbs.toInt())}g', l10n.getString('nutrition.carbs')),
              _buildSummaryItem('${l10n.formatInteger(analysisResult.totalFat.toInt())}g', l10n.getString('nutrition.fat')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(
    String name,
    String cals,
    Map<String, String> details,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                cals,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: details.entries
                .map(
                  (e) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${e.key}: ',
                        style: TextStyle(
                          color: _getMacroColor(e.key),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        e.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
        ),
      ],
    );
  }

  Color _getMacroColor(String key) {
    switch (key.toLowerCase()) {
      case 'protein':
        return const Color(0xFF00C853);
      case 'carbs':
        return const Color(0xFFFB923C);
      case 'fat':
        return const Color(0xFF60A5FA);
      case 'fiber':
        return const Color(0xFFA78BFA);
      case 'sodium':
        return const Color(0xFFF87171);
      default:
        return Colors.white38;
    }
  }

  Widget _buildAiInsights(LanguageProvider l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFA78BFA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.getString('ai_food.ai_insights'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...analysisResult.aiInsights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildInsightPoint(insight),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, color: Color(0xFFA78BFA), size: 6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, LanguageProvider l10n) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.nutritionGreenGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withAlpha(40),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final food = Food(
                  name: analysisResult.dishName,
                  servingSize: '1 portion',
                  calories: analysisResult.totalCalories,
                  protein: analysisResult.totalProtein,
                  carbs: analysisResult.totalCarbs,
                  fat: analysisResult.totalFat,
                );
                NutritionController().addMeal(mealType, food, 1.0);
                // Go back to scanning screen or nutrition dashboard
                Navigator.of(context).pop(); 
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    l10n.getString('ai_food.add_to_log'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    l10n.getString('ai_food.scan_different'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
