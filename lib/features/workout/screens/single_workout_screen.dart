import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../models/ai_workout_plan.dart';
import '../controllers/workout_controller.dart';

class SingleWorkoutScreen extends StatefulWidget {
  final String workoutName;
  final List<AiWorkoutExercise> exercises;
  final int startIndex;
  
  const SingleWorkoutScreen({
    super.key,
    required this.workoutName,
    required this.exercises,
    this.startIndex = 0,
  });

  @override
  State<SingleWorkoutScreen> createState() => _SingleWorkoutScreenState();
}

class _SingleWorkoutScreenState extends State<SingleWorkoutScreen> {
  late int _currentExerciseIndex;
  int _currentRepClickCount = 0;
  final _workoutController = WorkoutController();

  @override
  void initState() {
    super.initState();
    _currentExerciseIndex = widget.startIndex;
  }

  void _onCtaPressed() {
    final l10n = context.read<LanguageProvider>();
    setState(() {
      _currentRepClickCount++;
      
      final currentExercise = widget.exercises[_currentExerciseIndex];
      if (_currentRepClickCount >= currentExercise.sets) {
        // Exercise completed
        if (_currentExerciseIndex < widget.exercises.length - 1) {
          _currentExerciseIndex++;
          _currentRepClickCount = 0;
          
          // Update global progress
          _workoutController.updateProgress(_currentExerciseIndex);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.getString('workout.well_done')} ${l10n.getString('workout.next_exercise')}: ${widget.exercises[_currentExerciseIndex].name}',
                style: const TextStyle(color: Colors.white),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // All exercises finished
          _workoutController.finishWorkout();
          _showWorkoutCompleteDialog();
        }
      }
    });
  }

  void _onPausePressed() {
    _workoutController.pauseWorkout(_currentExerciseIndex);
    Navigator.pop(context);
  }

  void _showWorkoutCompleteDialog() {
    final l10n = context.read<LanguageProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: Text(l10n.getString('workout.workout_complete'), style: const TextStyle(color: Colors.white)),
        content: Text(l10n.getString('workout.workout_complete_msg'), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to workout list
            },
            child: Text(l10n.getString('workout.finish'), style: const TextStyle(color: AppColors.workoutPurple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();
    if (widget.exercises.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.workoutPurple,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.getString('workout.no_exercises'), style: const TextStyle(color: Colors.white)),
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.getString('workout.go_back'), style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
    }

    final currentExercise = widget.exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: AppColors.workoutPurple,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const SizedBox(height: 20),
            _buildProgressSection(l10n),
            const Spacer(),
            _buildExerciseDetail(currentExercise, l10n),
            const Spacer(),
            _buildCompleteButton(currentExercise, l10n),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _onPausePressed,
              child: Text(
                l10n.getString('workout.pause_workout'),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _onPausePressed,
          ),
          const Spacer(),
          Text(
            widget.workoutName,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance for arrow
        ],
      ),
    );
  }

  Widget _buildProgressSection(LanguageProvider l10n) {
    double progress = (_currentExerciseIndex) / widget.exercises.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.getString('workout.exercise')} ${l10n.formatInteger(_currentExerciseIndex + 1)} ${l10n.getString('workout.of')} ${l10n.formatInteger(widget.exercises.length)}',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress == 0 ? 0.05 : progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetail(AiWorkoutExercise exercise, LanguageProvider l10n) {
    return Column(
      children: [
        const Text(
          '\u{1F4AA}',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            l10n.translateDigits(exercise.reps),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${l10n.getString('workout.goal')}: ${l10n.translateDigits(exercise.reps)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${l10n.getString('workout.count')}: ${l10n.formatInteger(_currentRepClickCount)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton(AiWorkoutExercise exercise, LanguageProvider l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _onCtaPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.workoutPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.getString('workout.complete_set'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
