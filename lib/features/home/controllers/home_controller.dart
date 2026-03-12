import 'package:flutter/foundation.dart';
import '../../../core/app_settings.dart';

import '../models/home_dashboard_model.dart';

class HomeController extends ChangeNotifier {
  HomeController()
    : _model = HomeDashboardModel(
        userName: AppSettings().userName ?? 'User',
        streakDays: 0,
        consumedCalories: 0,
        targetCalories: 2000,
        workoutsCompleted: 0,
        dayStreak: 0,
      );

  final HomeDashboardModel _model;

  HomeDashboardModel get model => _model;
}
