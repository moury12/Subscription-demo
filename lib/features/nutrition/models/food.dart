class Food {
  final String name;
  final String servingSize;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  Food({
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  String get macroSummary => '${calories.toInt()} cal • P:${protein.toInt()}g • C:${carbs.toInt()}g • F:${fat.toInt()}g';
}
