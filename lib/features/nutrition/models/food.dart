class Food {
  final String name;
  final String servingSize;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final String? sodium;

  Food({
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sodium,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'] as String,
      servingSize: json['servingSize'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
      sodium: json['sodium'] as String?,
    );
  }

  String get macroSummary => '${calories.toInt()} cal • P:${protein.toInt()}g • C:${carbs.toInt()}g • F:${fat.toInt()}g';
}

class AiFoodAnalysisResult {
  final String dishName;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<Food> ingredients;
  final List<String> aiInsights;

  AiFoodAnalysisResult({
    required this.dishName,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.ingredients,
    required this.aiInsights,
  });

  factory AiFoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiFoodAnalysisResult(
      dishName: json['dishName'] as String,
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => Food.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiInsights: (json['aiInsights'] as List<dynamic>).cast<String>(),
    );
  }
}
