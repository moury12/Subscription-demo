import '../models/progress_model.dart';

class ProgressController {
  const ProgressController();

  ProgressModel get model => const ProgressModel(workoutsCompleted: 0, streak: 0);
}
