import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_settings.dart';
import '../../main/controllers/navigation_controller.dart';
import '../controllers/burn_history_controller.dart';
import '../../nutrition/controllers/nutrition_controller.dart';
import '../../workout/controllers/workout_controller.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  static const int _progressTabIndex = 3;

  final _nutritionController = NutritionController();
  final _burnController = BurnHistoryController();
  final _workoutController = WorkoutController();
  final _navController = NavigationController();
  final _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _nutritionController.addListener(_rebuild);
    _burnController.addListener(_rebuild);
    _workoutController.addListener(_rebuild);
    // IndexedStack + const child widgets can skip rebuilding this screen when
    // AppSettings change on another tab; refresh when the Progress tab is shown.
    _navController.addListener(_onNavigationChanged);
  }

  @override
  void dispose() {
    _nutritionController.removeListener(_rebuild);
    _burnController.removeListener(_rebuild);
    _workoutController.removeListener(_rebuild);
    _navController.removeListener(_onNavigationChanged);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _onNavigationChanged() {
    if (!mounted) return;
    if (_navController.currentIndex == _progressTabIndex) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          _buildProgressHeader(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildWorkoutConsistencyCard(),
                const SizedBox(height: 16),
                _buildCalorieTrackingCard(),
                const SizedBox(height: 100), // Bottom padding for nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      backgroundColor: Colors.transparent,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 40,
              right: 40,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.progressOrange.withOpacity(0.4),
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
                gradient: AppColors.progressOrangeGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Progress',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your fitness journey',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
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

  Widget _buildSummaryCard() {
    int totalWorkoutDays = _settings.currentPlan?.days.where((d) => !d.isRestDay).length ?? 0;
    int completedCount = _workoutController.completedCount;
    double avgCalories = _nutritionController.totalCalories;
    bool onTarget = (_nutritionController.totalCalories - _settings.targetCalories).abs() < 200;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111418),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This Week\'s Summary',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.calendar_today_rounded, color: Colors.blue.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'Workouts Completed', 
            '$completedCount/$totalWorkoutDays',
            icon: completedCount > 0 ? Icons.check_circle_rounded : Icons.cancel_outlined, 
            iconColor: completedCount > 0 ? Colors.tealAccent.shade400 : Colors.white38
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Average Calories', '${avgCalories.toInt()} cal'),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'On Target Days', 
            onTarget ? '1/7' : '0/7', // Placeholder for daily target tracking
            icon: Icons.check_circle_rounded, 
            iconColor: onTarget ? Colors.tealAccent.shade400 : Colors.white12
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, color: iconColor, size: 16),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    final double? current = _settings.currentWeight;
    final double? entry = _settings.entryWeight;
    final double weightChange = (current != null && entry != null)
        ? (current - entry)
        : 0.0;

    return Row(
      children: [
        _buildStatCard(_nutritionController.totalCalories.toInt().toString(), 'Consumption'),
        const SizedBox(width: 12),
        _buildStatCard(weightChange.toStringAsFixed(1), 'kg Change'),
        const SizedBox(width: 12),
        _buildStatCard(_burnController.totalBurnedToday.toInt().toString(), 'Total Burn'),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutConsistencyCard() {
    int totalWorkoutDays = _settings.currentPlan?.days.where((d) => !d.isRestDay).length ?? 7;
    int completedCount = _workoutController.completedCount;
    double completionRate = (completedCount / totalWorkoutDays) * 100;

    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text('Workout Consistency', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${completionRate.toInt()}% complete', style: const TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            height: 120,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                // Check if workout was completed for this day's title if plans exist
                bool isDone = false;
                if (_settings.currentPlan != null) {
                  final dayPlan = _settings.currentPlan!.days.firstWhere((d) => d.day.contains(day), orElse: () => _settings.currentPlan!.days.first);
                  isDone = _workoutController.isWorkoutCompleted(dayPlan.title);
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: isDone ? 80 : 2, 
                      width: 30, 
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.progressOrange : Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(day, style: const TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieTrackingCard() {
    double calories = _nutritionController.totalCalories;
    double target = _settings.targetCalories.toDouble();
    double ratio = (calories / target).clamp(0.01, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calorie Tracking', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildYAxisLabels(),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCalorieBar('Tue', 0.1),
                      _buildCalorieBar('Wed', 0.1),
                      _buildCalorieBar('Thu', 0.1),
                      _buildCalorieBar('Fri', 0.1),
                      _buildCalorieBar('Sat', 0.1),
                      _buildCalorieBar('Sun', 0.1),
                      _buildCalorieBar('Mon', ratio), 
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.accentGreen, 'Consumed'),
              const SizedBox(width: 24),
              _buildLegend(Colors.white, 'Target'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabels() {
    int target = _settings.targetCalories;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${(target * 1.5).toInt()}', style: const TextStyle(color: Colors.white24, fontSize: 10)),
        Text('${target}', style: const TextStyle(color: Colors.white24, fontSize: 10)),
        Text('${(target * 0.5).toInt()}', style: const TextStyle(color: Colors.white24, fontSize: 10)),
        const Text('0', style: TextStyle(color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  Widget _buildCalorieBar(String day, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}
