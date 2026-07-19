import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_settings.dart';
import '../../../core/providers/language_provider.dart';
import '../../main/controllers/navigation_controller.dart';
import '../controllers/burn_history_controller.dart';
import '../controllers/weight_history_controller.dart';
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
  final _weightController = WeightHistoryController();
  final _navController = NavigationController();
  final _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _nutritionController.addListener(_rebuild);
    _burnController.addListener(_rebuild);
    _workoutController.addListener(_rebuild);
    _weightController.addListener(_rebuild);
    _navController.addListener(_onNavigationChanged);
  }

  @override
  void dispose() {
    _nutritionController.removeListener(_rebuild);
    _burnController.removeListener(_rebuild);
    _workoutController.removeListener(_rebuild);
    _weightController.removeListener(_rebuild);
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
    final l10n = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: () async {
          await Future.wait([
            _nutritionController.loadFromDatabase(),
            _workoutController.loadFromDatabase(),
            _burnController.loadFromDatabase(),
            _weightController.loadFromDatabase(),
          ]);
          if (mounted) setState(() {});
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildProgressHeader(context, l10n),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSummaryCard(l10n),
                  const SizedBox(height: 16),
                  _buildStatsRow(l10n),
                  const SizedBox(height: 24),
                  _buildWorkoutConsistencyCard(l10n),
                  const SizedBox(height: 16),
                  _buildWeightProgressCard(l10n),
                  const SizedBox(height: 16),
                  _buildCalorieTrackingCard(l10n),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, LanguageProvider l10n) {
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
                      Text(
                        l10n.getString('progress.progress'),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.getString('progress.journey_desc'),
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

  Widget _buildSummaryCard(LanguageProvider l10n) {
    final currentPlan = _settings.currentWeekPlan;
    int totalWorkoutDays = (currentPlan != null ? currentPlan.days.where((d) => !d.isRestDay).length : 0);
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
              Text(
                l10n.getString('progress.weekly_summary'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.calendar_today_rounded, color: Colors.blue.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            l10n.getString('progress.workouts_completed'), 
            '${l10n.formatInteger(completedCount)}/${l10n.formatInteger(totalWorkoutDays)}',
            icon: completedCount > 0 ? Icons.check_circle_rounded : Icons.cancel_outlined, 
            iconColor: completedCount > 0 ? Colors.tealAccent.shade400 : Colors.white38
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(l10n.getString('progress.average_calories'), '${l10n.formatCalories(avgCalories.toInt())} ${l10n.getString('nutrition.cal_unit')}'),
          const SizedBox(height: 16),
          _buildSummaryRow(
            l10n.getString('progress.on_target_days'), 
            onTarget ? '${l10n.formatInteger(1)}/${l10n.formatInteger(7)}' : '${l10n.formatInteger(0)}/${l10n.formatInteger(7)}', 
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

  Widget _buildStatsRow(LanguageProvider l10n) {
    final double? current = _settings.currentWeight;
    final double? entry = _settings.entryWeight;
    final double weightChange = (current != null && entry != null)
        ? (current - entry)
        : _weightController.totalChange;

    return Row(
      children: [
        _buildStatCard(context, l10n.formatCalories(_nutritionController.totalCalories.toInt()), l10n.getString('progress.consumption')),
        const SizedBox(width: 12),
        _buildStatCard(context, '${weightChange >= 0 ? '+' : ''}${l10n.formatWeight(weightChange)}', l10n.getString('progress.weight_change')),
        const SizedBox(width: 12),
        _buildStatCard(context, l10n.formatCalories(_burnController.totalBurnedToday.toInt()), l10n.getString('progress.total_burn')),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
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
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutConsistencyCard(LanguageProvider l10n) {
    final currentPlan = _settings.currentWeekPlan;
    int totalWorkoutDays = (currentPlan != null ? currentPlan.days.where((d) => !d.isRestDay).length : 7);
    int completedCount = _workoutController.completedCount;
    double completionRate = totalWorkoutDays > 0 ? (completedCount / totalWorkoutDays) * 100 : 0;

    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

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
              Text(l10n.getString('progress.workout_consistency'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${l10n.formatPercentage(completionRate.toInt())} ${l10n.getString('progress.complete')}', style: const TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            height: 120,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((dayName) {
                final dayKey = dayName.toLowerCase();
                final dayInitial = l10n.getString('days.$dayKey').substring(0, 1);
                
                // Check if workout was completed for this day's title if plans exist
                bool isDone = false;
                if (currentPlan != null) {
                  try {
                    final dayPlan = currentPlan.days.firstWhere((d) => d.day.toLowerCase().contains(dayKey.substring(0,3)));
                    isDone = _workoutController.isWorkoutCompleted(dayPlan.title);
                  } catch (_) {}
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
                    Text(dayInitial, style: const TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieTrackingCard(LanguageProvider l10n) {
    double calories = _nutritionController.totalCalories;
    double target = _settings.targetCalories.toDouble();
    double ratio = (calories / target).clamp(0.01, 1.0);

    final days = [
      'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'Monday'
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.getString('progress.calorie_tracking'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildYAxisLabels(l10n),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: days.map((dayName) {
                      final dayKey = dayName.toLowerCase();
                      final dayInitial = l10n.getString('days.$dayKey').substring(0, 1);
                      // Placeholder logic: Current day (Mon mock) uses real ratio, others use 0.1
                      final isCurrentMockDay = dayName == 'Monday';
                      return _buildCalorieBar(dayInitial, isCurrentMockDay ? ratio : 0.1);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.accentGreen, l10n.getString('progress.consumed')),
              const SizedBox(width: 24),
              _buildLegend(Colors.white, l10n.getString('progress.target')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabels(LanguageProvider l10n) {
    int target = _settings.targetCalories;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.formatInteger((target * 1.5).toInt()), style: const TextStyle(color: Colors.white24, fontSize: 10)),
        Text(l10n.formatInteger(target), style: const TextStyle(color: Colors.white24, fontSize: 10)),
        Text(l10n.formatInteger((target * 0.5).toInt()), style: const TextStyle(color: Colors.white24, fontSize: 10)),
        Text(l10n.formatInteger(0), style: const TextStyle(color: Colors.white24, fontSize: 10)),
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

  Widget _buildWeightProgressCard(LanguageProvider l10n) {
    final entries = _weightController.history;
    final current = _settings.currentWeight;
    final entry = _settings.entryWeight;
    final target = _settings.targetWeight;

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
              Text(
                l10n.getString('progress.weight_progress'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (current != null)
                Text(
                  l10n.formatWeight(current),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWeightStat(
                l10n.getString('onboarding.start'),
                entry != null ? l10n.formatWeight(entry) : '—',
                Colors.blue.shade400,
              ),
              const SizedBox(width: 16),
              _buildWeightStat(
                l10n.getString('onboarding.current'),
                current != null ? l10n.formatWeight(current) : ' —',
                AppColors.progressOrange,
              ),
              const SizedBox(width: 16),
              _buildWeightStat(
                l10n.getString('onboarding.goal'),
                target != null ? l10n.formatWeight(target) : '—',
                Colors.tealAccent.shade400,
              ),
            ],
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Text(
              l10n.getString('progress.recent_changes'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.take(5).map((e) {
              final changeStr = e.change != null
                  ? '${e.change! >= 0 ? '+' : ''}${l10n.formatWeight(e.change!)}'
                  : l10n.getString('progress.initial');
              final isLoss = (e.change ?? 0) < 0;
              final isGain = (e.change ?? 0) > 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLoss
                            ? Colors.tealAccent.shade400
                            : isGain
                                ? Colors.redAccent
                                : Colors.white38,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.formatWeight(e.weight),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      changeStr,
                      style: TextStyle(
                        color: isLoss
                            ? Colors.tealAccent.shade400
                            : isGain
                                ? Colors.redAccent
                                : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, yyyy').format(e.date),
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  l10n.getString('progress.no_history'),
                  style: const TextStyle(color: Colors.white24, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
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
