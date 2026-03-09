import 'package:flutter/foundation.dart';

import '../models/home_dashboard_model.dart';

class HomeController extends ChangeNotifier {
  HomeController()
    : _model = const HomeDashboardModel(
        userName: 'Jhon Deo',
        streakDays: 0,
        consumedCalories: 0,
        targetCalories: 0,
        workoutsCompleted: 0,
        dayStreak: 0,
      );

  final HomeDashboardModel _model;

  HomeDashboardModel get model => _model;
}
