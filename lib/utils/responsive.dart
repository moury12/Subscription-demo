import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class DesignScale {
  DesignScale._(this.widthScale);

  factory DesignScale.fromConstraints(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 393.0;
    final scale = (maxWidth / 393.0).clamp(0.85, 1.2);
    return DesignScale._(scale);
  }

  final double widthScale;

  double s(double value) => value * widthScale;

  double clampHeight(double value) => math.max(0, value * widthScale);
}
