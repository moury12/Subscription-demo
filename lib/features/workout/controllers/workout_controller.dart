import '../models/workout_model.dart';

class WorkoutController {
  const WorkoutController();

  List<WorkoutModel> get plans => const [
    WorkoutModel(title: 'Beginner Plan', subtitle: 'Exercise 1-3 days/week'),
    WorkoutModel(title: 'Intermediate Plan', subtitle: 'Exercise 3-5 days/week'),
    WorkoutModel(title: 'Advanced Plan', subtitle: 'Exercise 6-7 days/week'),
  ];
}
