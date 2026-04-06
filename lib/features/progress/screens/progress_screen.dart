import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/burn_history_controller.dart';
import '../../nutrition/controllers/nutrition_controller.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _nutritionController = NutritionController();
  final _burnController = BurnHistoryController();

  @override
  void initState() {
    super.initState();
    _nutritionController.addListener(_rebuild);
    _burnController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _nutritionController.removeListener(_rebuild);
    _burnController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
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
                const SizedBox(height: 16),
                // _buildAchievementsCard(),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your fitness journey',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
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

  Widget _buildSummaryCard() {
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
          _buildSummaryRow('Workouts Completed', '0/7',
              icon: Icons.cancel_outlined, iconColor: Colors.white38),
          const SizedBox(height: 16),
          _buildSummaryRow('Average Calories', '${_nutritionController.totalCalories.toInt()} cal'),
          const SizedBox(height: 16),
          _buildSummaryRow('On Target Days', '7/7',
              icon: Icons.check_circle_rounded, iconColor: Colors.tealAccent.shade400),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, color: iconColor, size: 16),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(_nutritionController.totalCalories.toInt().toString(), 'Consumption'),
        const SizedBox(width: 12),
        _buildStatCard('0.0', 'kg Change'),
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
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutConsistencyCard() {
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
              const Text('Workout Consistency',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('0% complete', style: TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 40),
          // Chart placeholder
          Container(
            height: 120,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon'].map((day) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(height: 1, width: 30, color: Colors.white12),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calorie Tracking',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // Bar chart placeholder
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
                      _buildCalorieBar('Mon', 0.8), // Example bar
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['180', '135', '90', '45', '0'].map((label) {
        return Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10));
      }).toList(),
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

  Widget _buildAchievementsCard() {
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
              const Text('Achievements',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('0/6', style: TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _buildAchievementItem('\u{1F916}', 'First\nWorkout'),
              _buildAchievementItem('\u{1F525}', '7 Day Streak'),
              _buildAchievementItem('\u{1F305}', 'Early Bird'),
              _buildAchievementItem('\u{1F3AF}', 'Calorie\nMaster'),
              _buildAchievementItem('\u{2B50}', 'Weight Goal'),
              _buildAchievementItem('\u{1F451}', 'Consistency\nKing'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String emoji, String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
