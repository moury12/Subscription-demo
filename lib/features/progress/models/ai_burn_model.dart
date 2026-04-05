class AiBurnActivity {
  final String activity;
  final String duration;
  final double caloriesBurned;
  final String? intensity;

  AiBurnActivity({
    required this.activity,
    required this.duration,
    required this.caloriesBurned,
    this.intensity,
  });

  factory AiBurnActivity.fromJson(Map<String, dynamic> json) {
    return AiBurnActivity(
      activity: json['activity'] ?? '',
      duration: json['duration'] ?? '',
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
      intensity: json['intensity'],
    );
  }
}

class AiBurnAnalysisResult {
  final double totalCaloriesBurned;
  final List<AiBurnActivity> activities;
  final String summary;

  AiBurnAnalysisResult({
    required this.totalCaloriesBurned,
    required this.activities,
    required this.summary,
  });

  factory AiBurnAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiBurnAnalysisResult(
      totalCaloriesBurned: (json['totalCaloriesBurned'] as num?)?.toDouble() ?? 0.0,
      activities: (json['activities'] as List? ?? [])
          .map((a) => AiBurnActivity.fromJson(a))
          .toList(),
      summary: json['summary'] ?? '',
    );
  }
}
