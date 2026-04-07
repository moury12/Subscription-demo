import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_settings.dart';
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

  @override
  void initState() {
    super.initState();
    _workoutController.addListener(_update);
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
    final settings = AppSettings();
    final plan = settings.currentPlan;
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
          _buildWorkoutHeader(context, plan),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_workoutController.activeWorkout != null && _workoutController.isPaused)
                    _buildInProgressSection(context, _workoutController.activeWorkout!),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'This Week',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (plan != null)
                    ...plan.days.map((dayPlan) {
                      return _buildWorkoutCard(
                        context,
                        dayPlan.title,
                        dayPlan.isRestDay ? 'Recovery / Mobility' : '${dayPlan.exercises.length} Exercises',
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
                        isRestDay ? 'Rest Day' : 'Push Up',
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

  Widget _buildWorkoutHeader(BuildContext context, AiWeeklyWorkoutPlan? plan) {
    int totalWorkouts = plan?.days.where((d) => !d.isRestDay).length ?? 0;
    int completedCount = _workoutController.completedCount;
    int progress = totalWorkouts > 0 ? (completedCount * 100 ~/ totalWorkouts) : 0;

    return SliverAppBar(
      expandedHeight: 380,
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
                      const Text(
                        'Workouts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your personalized training plan',
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
                            Expanded(child: _buildHeaderStat(completedCount.toString(), 'Completed')),
                            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                            Expanded(child: _buildHeaderStat(totalWorkouts.toString(), 'Total')),
                            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                            Expanded(child: _buildHeaderStat('$progress%', 'Progress')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'This Week',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      _buildDatePicker(),
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

  Widget _buildDatePicker() {
    final weekStartDay = AppSettings().weekStartDay;
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
      String dayName = DateFormat('E').format(date);

      if (isToday) {
        dateItems.add(
          Column(
            children: [
              Text(dayName, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
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
        dateItems.add(_buildDateItem(date.day.toString(), dayName, false));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dateItems,
    );
  }

  Widget _buildDateItem(String day, String weekday, bool isSelected) {
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

  Widget _buildInProgressSection(BuildContext context, AiWorkoutDay dayPlan) {
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
                'Workout in Progress',
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
                    dayPlan.isRestDay ? 'Rest & Recovery' : dayPlan.title,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayPlan.isRestDay ? 'Active recovery or yoga' : 'Exercise ${currentIndex + 1} of ${dayPlan.exercises.length}',
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
              child: const Text('Resume Workout', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, String title, String subtitle, String day, AiWorkoutDay? dayPlan) {
    final isCompleted = _workoutController.isWorkoutCompleted(title);
    
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
                color: isCompleted ? Colors.green : const Color(0xFF8B5CF6),
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
