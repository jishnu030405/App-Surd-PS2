class AiSummary {
  final String overallExperience;
  final List<String> positiveFeatures;
  final List<String> reportedBarriers;
  final List<String> conflictingReports;
  final List<String> needsVerification;
  final String summaryText;
  final int reviewsAnalyzedCount;
  final DateTime generatedAt;
  final bool isLiveAi;

  const AiSummary({
    required this.overallExperience,
    required this.positiveFeatures,
    required this.reportedBarriers,
    required this.conflictingReports,
    required this.needsVerification,
    required this.summaryText,
    required this.reviewsAnalyzedCount,
    required this.generatedAt,
    this.isLiveAi = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'overallExperience': overallExperience,
      'positiveFeatures': positiveFeatures,
      'reportedBarriers': reportedBarriers,
      'conflictingReports': conflictingReports,
      'needsVerification': needsVerification,
      'summaryText': summaryText,
      'reviewsAnalyzedCount': reviewsAnalyzedCount,
      'generatedAt': generatedAt.toIso8601String(),
      'isLiveAi': isLiveAi,
    };
  }

  factory AiSummary.fromJson(Map<String, dynamic> json) {
    return AiSummary(
      overallExperience: json['overallExperience'] as String? ?? '',
      positiveFeatures: (json['positiveFeatures'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      reportedBarriers: (json['reportedBarriers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      conflictingReports: (json['conflictingReports'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      needsVerification: (json['needsVerification'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      summaryText: json['summaryText'] as String? ?? '',
      reviewsAnalyzedCount: (json['reviewsAnalyzedCount'] as num?)?.toInt() ?? 0,
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isLiveAi: json['isLiveAi'] as bool? ?? false,
    );
  }
}
