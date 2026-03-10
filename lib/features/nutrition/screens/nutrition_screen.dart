import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/nutrition_controller.dart';
import 'add_meal_screen.dart';
import '../widgets/meal_logging_options.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _controller = NutritionController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildNutritionHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    children: [
                      _buildCalorieCard(),
                      const SizedBox(height: 32),
                      _buildMealSection('Breakfast', Icons.coffee_rounded, const Color(0xFF00C853)),
                      const SizedBox(height: 24),
                      _buildMealSection('Lunch', Icons.wb_sunny_rounded, const Color(0xFF34D399)),
                      const SizedBox(height: 24),
                      _buildMealSection('Dinner', Icons.mode_night_rounded, const Color(0xFF00E676)),
                      const SizedBox(height: 24),
                      _buildMealSection('Snack', Icons.cookie_rounded, const Color(0xFF00C853)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => MealLoggingOptions.showAddOptions(context),
              backgroundColor: const Color(0xFF2E6FFC),
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNutritionHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      backgroundColor: Colors.transparent,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Header Glow
            Positioned(
              bottom: 0,
              left: 40,
              right: 40,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.nutritionGreenGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Nutrition',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your daily meals and macros',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard() {
    final total = _controller.totalCalories.toInt();
    final progress = (total / 2000).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Calories',
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' /',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '0 cal remaining',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress > 0 ? progress : 0.01,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      color: AppColors.accentGreen,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGlowingMacro('6g', 'Protein', '/g'),
              _buildGlowingMacro('6g', 'Carbs', '/g'),
              _buildGlowingMacro('14g', 'Fat', '/g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingMacro(String value, String label, String sublabel) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.1),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                   Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 20),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          sublabel,
          style: const TextStyle(color: Colors.white24, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildMealSection(String title, IconData icon, Color color) {
    final meals = _controller.loggedMeals.where((m) => m.type == title).toList();
    final sectionCals = meals.fold(0.0, (sum, m) => sum + m.food.calories).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
               sectionCals > 0 ? '$sectionCals cal' : '',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          GestureDetector(
            onTap: () => _openAddMeal(title),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: Column(
                children: [
                  const Text('No meals logged yet', style: TextStyle(color: Colors.white38, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('+ Add $title', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        else
          ...meals.map((m) => _buildLoggedMealCard(m)),
      ],
    );
  }

  Widget _buildLoggedMealCard(LoggedMeal loggedMeal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loggedMeal.food.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${loggedMeal.food.calories.toInt()} cal • P: ${loggedMeal.food.protein.toInt()}g • C: ${loggedMeal.food.carbs.toInt()}g • F: ${loggedMeal.food.fat.toInt()}g',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Dashboard', false),
          _buildNavItem(Icons.fitness_center_rounded, 'Workout', false),
          _buildNavItem(Icons.apple_rounded, 'Nutrition', true),
          _buildNavItem(Icons.trending_up_rounded, 'Progress', false),
          _buildNavItem(Icons.person_outline_rounded, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.white : Colors.white38, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 10,
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 24,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              boxShadow: [
                BoxShadow(color: AppColors.accentGreen.withOpacity(0.8), blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
      ],
    );
  }

  void _openAddMeal(String type) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => AddMealScreen(initialMealType: type)),
    );
    if (result != null && result['food'] != null) {
      _controller.addMeal(type, result['food'], result['multiplier'] ?? 1.0);
    }
  }
}
