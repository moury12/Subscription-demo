import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_settings.dart';
import '../../../core/providers/language_provider.dart';
import '../models/ai_workout_plan.dart';
import '../controllers/workout_controller.dart';
import 'single_workout_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _workoutController = WorkoutController();
  AiWeeklyWorkoutPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _workoutController.addListener(_update);
    _selectCurrentWeekPlan();
  }

  void _selectCurrentWeekPlan() {
    final plans = AppSettings().workoutPlans;
    if (plans.isEmpty) return;

    final now = DateTime.now();
    for (final plan in plans) {
      if (plan.coversDate(now)) {
        _selectedPlan = plan;
        return;
      }
    }
    _selectedPlan = plans.first;
  }

  @override
  void dispose() {
    _workoutController.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();
    final settings = AppSettings();
    if (_selectedPlan == null && settings.workoutPlans.isNotEmpty) {
      _selectCurrentWeekPlan();
    }
    final AiWeeklyWorkoutPlan? plan = _selectedPlan;
    final weekStartDay = settings.weekStartDay;
    final now = DateTime.now();
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    int currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    int targetWeekdayIndex = daysOfWeek.indexOf(weekStartDay) + 1;

    int daysToBack = (currentWeekday - targetWeekdayIndex) % 7;
    if (daysToBack < 0) daysToBack += 7;

    DateTime weekStart = now.subtract(Duration(days: daysToBack));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          _buildWorkoutHeader(context, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_workoutController.activeWorkout != null && _workoutController.isPaused)
                    _buildInProgressSection(context, l10n, _workoutController.activeWorkout!),
                  
                  const SizedBox(height: 32),
                  Text(
                    l10n.getString('workout.this_week'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPlan != null)
                    ..._selectedPlan!.days.map((dayPlan) {
                      final localizedExercises = l10n.getString('workout.exercises');
                      final localizedRecovery = l10n.getString('workout.recovery');
                      return _buildWorkoutCard(
                        context,
                        dayPlan.title,
                        dayPlan.isRestDay ? localizedRecovery : '${l10n.formatInteger(dayPlan.exercises.length)} $localizedExercises',
                        dayPlan.day,
                        dayPlan,
                      );
                    }).toList()
                  else
                    ...List.generate(7, (index) {
                      final date = weekStart.add(Duration(days: index));
                      final dayName = DateFormat('EEEE').format(date);
                      final isRestDay = index > 0;
                      return _buildWorkoutCard(
                        context,
                        isRestDay ? l10n.getString('workout.rest_day') : 'Push Up',
                        isRestDay ? '0 0/0 completed' : '35 min • 0/5 completed',
                        dayName,
                        null,
                      );
                    }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader(BuildContext context, LanguageProvider l10n) {
    final allPlans = AppSettings().workoutPlans;
    final plan = _selectedPlan;

    int totalWorkouts = plan?.days.where((d) => !d.isRestDay).length ?? 0;
    int completedCount = _workoutController.completedCount;
    int progress = totalWorkouts > 0 ? (completedCount * 100 ~/ totalWorkouts) : 0;

    return SliverAppBar(
      expandedHeight: 420, // Increased height to accommodate dropdown
      backgroundColor: Colors.transparent,
      pinned: false,
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
                      color: AppColors.workoutPurple.withOpacity(0.4),
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
                gradient: AppColors.workoutPurpleGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Dropdown for selecting workout plans
                      if (allPlans.length > 1) // Only show dropdown if there's more than one plan
                        DropdownButton<AiWeeklyWorkoutPlan>(
                          value: _selectedPlan,
                          dropdownColor: AppColors.darkBackground,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          onChanged: (AiWeeklyWorkoutPlan? newValue) {
                            setState(() {
                              _selectedPlan = newValue;
                            });
                          },
                          items: allPlans.map<DropdownMenuItem<AiWeeklyWorkoutPlan>>((AiWeeklyWorkoutPlan value) {
                            return DropdownMenuItem<AiWeeklyWorkoutPlan>(
                              value: value,
                              child: Text(
                                '${value.planTitle} (${value.startDate != null ? DateFormat('MMM d, yyyy').format(value.startDate!) : 'N/A'})',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ) else if (plan != null) // If only one plan, just display its title
                        Text(
                          plan.planTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        plan != null
                            ? '${l10n.getString('workout.week')} ${l10n.formatInteger(plan.weekNumber)}${plan.startDate != null ? ' • ${l10n.translateDigits(DateFormat('MMM d').format(plan.startDate!))} – ${l10n.translateDigits(DateFormat('MMM d').format(plan.endDate ?? plan.startDate!.add(const Duration(days: 6))))}' : ''}'
                            : l10n.getString('workout.weekly_plan_desc'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildHeaderStat(l10n.formatInteger(completedCount), l10n.getString('workout.completed'))),
                            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                            Expanded(child: _buildHeaderStat(l10n.formatInteger(totalWorkouts), l10n.getString('workout.total'))),
                            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                            Expanded(child: _buildHeaderStat(l10n.formatPercentage(progress), l10n.getString('workout.progress'))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.getString('workout.this_week'),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      _buildDatePicker(l10n),
                      const SizedBox(height: 10),
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

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDatePicker(LanguageProvider l10n) {
    final settings = AppSettings();
    final weekStartDay = settings.weekStartDay;
    final now = DateTime.now();
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    int currentWeekday = now.weekday;
    int targetWeekdayIndex = daysOfWeek.indexOf(weekStartDay) + 1;
    int daysToBack = (currentWeekday - targetWeekdayIndex) % 7;
    if (daysToBack < 0) daysToBack += 7;
    DateTime weekStart = now.subtract(Duration(days: daysToBack));

    List<Widget> dateItems = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = weekStart.add(Duration(days: i));
      bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;
      // Get localized day initial (e.g., M, T, W or Hindi equivalents)
      String fullDayName = DateFormat('EEEE').format(date);
      String dayInitial = l10n.getString('days.${fullDayName.toLowerCase()}').substring(0, 1);

      if (isToday) {
        dateItems.add(
          Column(
            children: [
              Text(dayInitial, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white54, blurRadius: 10, spreadRadius: 1)],
                ),
                child: const Icon(Icons.calendar_today_outlined, color: AppColors.workoutPurple, size: 20),
              ),
            ],
          ),
        );
      } else {
        dateItems.add(_buildDateItem(context, l10n.formatInteger(date.day), dayInitial, false));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dateItems,
    );
  }

  Widget _buildDateItem(BuildContext context, String day, String weekday, bool isSelected) {
    return Column(
      children: [
        Text(weekday, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            color: isSelected ? Colors.white : Colors.transparent,
          ),
          child: Text(
            day,
            style: TextStyle(
              color: isSelected ? AppColors.workoutPurple : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressSection(BuildContext context, LanguageProvider l10n, AiWorkoutDay dayPlan) {
    final currentIndex = _workoutController.currentExerciseIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                l10n.getString('workout.in_progress'),
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayPlan.isRestDay ? l10n.getString('workout.rest_recovery') : dayPlan.title,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayPlan.isRestDay 
                      ? l10n.getString('workout.active_recovery') 
                      : '${l10n.getString('workout.exercise')} ${l10n.formatInteger(currentIndex + 1)} ${l10n.getString('workout.of')} ${l10n.formatInteger(dayPlan.exercises.length)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _workoutController.resumeWorkout();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SingleWorkoutScreen(
                    workoutName: dayPlan.title,
                    exercises: dayPlan.exercises,
                    startIndex: currentIndex,
                  )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.getString('workout.resume_workout'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, String title, String subtitle, String day, AiWorkoutDay? dayPlan) {
    final isCompleted = _workoutController.isWorkoutCompleted(title);
    final isPausedActiveWorkout =
        _workoutController.isPaused &&
        _workoutController.activeWorkout != null &&
        _workoutController.activeWorkout!.title == title;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    if (isCompleted) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white.withOpacity(0.5), size: 14),
                    const SizedBox(width: 4),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (dayPlan != null && !dayPlan.isRestDay) {
                _workoutController.startWorkout(dayPlan);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SingleWorkoutScreen(
                    workoutName: title,
                    exercises: dayPlan.exercises,
                  )),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isPausedActiveWorkout
                        ? Colors.orange
                        : const Color(0xFF8B5CF6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
