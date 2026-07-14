class ProductContaminant {
  final String name;
  final String value;
  final String status; // 'safe', 'warning', 'danger'

  ProductContaminant({
    required this.name,
    required this.value,
    required this.status,
  });

  factory ProductContaminant.fromJson(Map<String, dynamic> json) {
    return ProductContaminant(
      name: json['name'] as String? ?? 'Unknown',
      value: json['value'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'safe',
    );
  }
}

class AdditionalVitamin {
  final String name;
  final String value;
  final bool isHealthy;

  AdditionalVitamin({
    required this.name,
    required this.value,
    required this.isHealthy,
  });

  factory AdditionalVitamin.fromJson(Map<String, dynamic> json) {
    return AdditionalVitamin(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      isHealthy: json['isHealthy'] as bool? ?? true,
    );
  }
}

class ProductNutritionFacts {
  final String calories;
  final String totalFat;
  final String? saturatedFat;
  final String sodium;
  final String? carbs;
  final String? sugar;
  final String? protein;
  final List<AdditionalVitamin> additionalVitamins;

  ProductNutritionFacts({
    required this.calories,
    required this.totalFat,
    this.saturatedFat,
    required this.sodium,
    this.carbs,
    this.sugar,
    this.protein,
    required this.additionalVitamins,
  });

  factory ProductNutritionFacts.fromJson(Map<String, dynamic> json) {
    var vitaminsList = json['additionalVitamins'] as List<dynamic>? ?? [];
    return ProductNutritionFacts(
      calories: json['calories'] as String? ?? '0 kcal',
      totalFat: json['totalFat'] as String? ?? '0g',
      saturatedFat: json['saturatedFat'] as String?,
      sodium: json['sodium'] as String? ?? '0mg',
      carbs: json['carbs'] as String?,
      sugar: json['sugar'] as String?,
      protein: json['protein'] as String?,
      additionalVitamins: vitaminsList
          .map((v) => AdditionalVitamin.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductAnalysisResult {
  final String productName;
  final String category;
  final String subtext;
  final double qualityScore;
  final String qualityRating;
  final int novaScale;
  final String novaRating;
  final ProductNutritionFacts nutritionFacts;
  final List<String> ingredients;
  final String additivesAlert;
  final List<String> allergens;
  final List<ProductContaminant> contaminants;

  ProductAnalysisResult({
    required this.productName,
    required this.category,
    required this.subtext,
    required this.qualityScore,
    required this.qualityRating,
    required this.novaScale,
    required this.novaRating,
    required this.nutritionFacts,
    required this.ingredients,
    required this.additivesAlert,
    required this.allergens,
    required this.contaminants,
  });

  factory ProductAnalysisResult.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List<dynamic>? ?? [];
    var allergensList = json['allergens'] as List<dynamic>? ?? [];
    var contaminantsList = json['contaminants'] as List<dynamic>? ?? [];

    return ProductAnalysisResult(
      productName: json['productName'] as String? ?? 'Unknown Product',
      category: json['category'] as String? ?? 'PACKAGED FOOD',
      subtext: json['subtext'] as String? ?? '',
      qualityScore: (json['qualityScore'] as num? ?? 0.0).toDouble(),
      qualityRating: json['qualityRating'] as String? ?? 'Fair',
      novaScale: json['novaScale'] as int? ?? 1,
      novaRating: json['novaRating'] as String? ?? 'Unprocessed',
      nutritionFacts: ProductNutritionFacts.fromJson(
          json['nutritionFacts'] as Map<String, dynamic>? ?? {}),
      ingredients: ingredientsList.cast<String>(),
      additivesAlert: json['additivesAlert'] as String? ?? '',
      allergens: allergensList.cast<String>(),
      contaminants: contaminantsList
          .map((c) => ProductContaminant.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
