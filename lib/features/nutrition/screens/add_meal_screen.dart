import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/food.dart';
import '../widgets/food_list_card.dart';
import '../widgets/nutrition_green_app_bar.dart';

class AddMealScreen extends StatefulWidget {
  final String initialMealType;
  const AddMealScreen({super.key, this.initialMealType = 'Breakfast'});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  late String _selectedMealType;
  final TextEditingController _searchController = TextEditingController();
  Food? _selectedFood;
  double _multiplier = 1.0;

  final List<Food> _commonFoods = [
    Food(name: 'Almonds (28g)', servingSize: '28g', calories: 164, protein: 6, carbs: 6, fat: 14),
    Food(name: 'Apple (medium)', servingSize: 'medium', calories: 95, protein: 0.5, carbs: 25, fat: 0.3),
    Food(name: 'Avocado (half)', servingSize: 'half', calories: 120, protein: 1.5, carbs: 6, fat: 11),
    Food(name: 'Banana (medium)', servingSize: 'medium', calories: 105, protein: 1.3, carbs: 27, fat: 0.4),
    Food(name: 'Broccoli (1 cup)', servingSize: '1 cup', calories: 55, protein: 3.7, carbs: 11, fat: 0.6),
    Food(name: 'Brown Rice (1 cup)', servingSize: '1 cup', calories: 216, protein: 5, carbs: 45, fat: 1.8),
    Food(name: 'Chicken Breast (100g)', servingSize: '100g', calories: 165, protein: 31, carbs: 0, fat: 3.6),
    Food(name: 'Eggs (2 large)', servingSize: '2 large', calories: 140, protein: 12, carbs: 1, fat: 10),
    Food(name: 'Greek Yogurt (1 cup)', servingSize: '1 cup', calories: 130, protein: 15, carbs: 11, fat: 3),
    Food(name: 'Oatmeal (1 cup)', servingSize: '1 cup', calories: 150, protein: 6, carbs: 27, fat: 3),
    Food(name: 'Peanut Butter (2 tbsp)', servingSize: '2 tbsp', calories: 190, protein: 8, carbs: 7, fat: 16),
    Food(name: 'Quinoa (1 cup)', servingSize: '1 cup', calories: 222, protein: 8, carbs: 39, fat: 3.6),
    Food(name: 'Salmon (100g)', servingSize: '100g', calories: 208, protein: 20, carbs: 0, fat: 13),
    Food(name: 'Sweet Potato (medium)', servingSize: 'medium', calories: 112, protein: 2, carbs: 26, fat: 0.1),
    Food(name: 'Tuna (100g)', servingSize: '100g', calories: 132, protein: 28, carbs: 0, fat: 1.3),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const NutritionGreenAppBar(title: 'Add Meal'),
      body: Column(
        children: [
          _buildMealTypeSelector(),
          Expanded(
            child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  if (_selectedFood != null) ...[
                    const Text('Selected Food', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 12),
                    _buildSelectedFoodCard(),
                    const SizedBox(height: 32),
                  ],
                  const Text('Common Foods', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 12),
                  ..._commonFoods.map((food) => FoodListCard(
                        food: food,
                        onTap: () => setState(() {
                          _selectedFood = food;
                          _multiplier = 1.0;
                        }),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    final types = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: types.map((type) {
          final isSelected = _selectedMealType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMealType = type),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentGreen : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.done,
        onEditingComplete: () => FocusManager.instance.primaryFocus?.unfocus(),
        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          hintText: 'Search for food...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(150)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectedFoodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGreen.withAlpha(50), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGreen.withAlpha(20),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedFood!.name,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedFood = null),
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _selectedFood!.macroSummary,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Servings: ${_multiplier.toStringAsFixed(1)}', style: AppTextStyles.labelMedium),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accentGreen,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: AppColors.accentGreen.withAlpha(30),
            ),
            child: Slider(
              value: _multiplier,
              min: 0.5,
              max: 5.0,
              onChanged: (val) => setState(() => _multiplier = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0.5x', style: AppTextStyles.caption.copyWith(color: Colors.white24)),
                Text('5x', style: AppTextStyles.caption.copyWith(color: Colors.white24)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.nutritionGreenGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).pop({
                    'food': _selectedFood,
                    'multiplier': _multiplier,
                  });
                },
                child: Center(
                  child: Text(
                    'Add to $_selectedMealType',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
