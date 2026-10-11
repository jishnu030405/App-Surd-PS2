import 'package:flutter/material.dart';
import '../models/accessibility_category.dart';
import '../theme/app_theme.dart';

class ScoreCalculationResult {
  final double? score; // 0 to 100 or null if not enough info
  final double coveragePercentage; // 0.0 to 100.0
  final int ratedCategoriesCount;
  final int totalCategoriesCount;
  final Map<AccessibilityCategory, double> contributions;

  const ScoreCalculationResult({
    required this.score,
    required this.coveragePercentage,
    required this.ratedCategoriesCount,
    required this.totalCategoriesCount,
    required this.contributions,
  });

  bool get hasSufficientData => score != null;

  int get roundedScore => score?.round() ?? 0;

  String get interpretationLabel {
    if (score == null) return 'Not Enough Info';
    final s = score!;
    if (s >= 85) return 'Highly Accessible';
    if (s >= 65) return 'Substantially Accessible';
    if (s >= 45) return 'Partially Accessible';
    return 'Significant Barriers';
  }

  String get shortStatus {
    if (score == null) return 'Unverified';
    final s = score!;
    if (s >= 85) return 'Highly Accessible';
    if (s >= 65) return 'Good Access';
    if (s >= 45) return 'Partial Access';
    return 'Barriers Present';
  }

  Color get statusColor {
    if (score == null) return AppTheme.statusSlate;
    final s = score!;
    if (s >= 85) return AppTheme.statusGreen;
    if (s >= 65) return AppTheme.primaryTeal;
    if (s >= 45) return AppTheme.statusAmber;
    return AppTheme.statusRed;
  }

  Color get statusBackgroundColor {
    if (score == null) return AppTheme.statusSlateLight;
    final s = score!;
    if (s >= 85) return AppTheme.statusGreenLight;
    if (s >= 65) return AppTheme.primaryTealLight;
    if (s >= 45) return AppTheme.statusAmberLight;
    return AppTheme.statusRedLight;
  }

  Color get statusBorderColor {
    if (score == null) return AppTheme.statusSlateBorder;
    final s = score!;
    if (s >= 85) return AppTheme.statusGreenBorder;
    if (s >= 65) return AppTheme.primaryTeal;
    if (s >= 45) return AppTheme.statusAmberBorder;
    return AppTheme.statusRedBorder;
  }

  String get detailedDescription {
    if (score == null) {
      return 'Insufficient community ratings have been reported for this location. Be the first to add a verification report.';
    }
    final s = score!;
    if (s >= 85) {
      return 'Meets comprehensive accessibility criteria across rated facilities. Recommended for wheelchair users and those with high mobility needs.';
    }
    if (s >= 65) {
      return 'Good general accessibility with most essential facilities available. Check specific category notes for minor considerations.';
    }
    if (s >= 45) {
      return 'Some accessibility features exist, but key barriers were reported. Prior planning or assistance may be required.';
    }
    return 'Substantial physical or navigational barriers reported. Independent wheelchair access may not be feasible currently.';
  }
}

class AccessibilityScoreCalculator {
  /// Calculates the overall accessibility score and data coverage percentage
  /// according to the weighted formula:
  ///
  /// For category i:
  /// Contribution_i = weight_i * (rating_i / 5)
  ///
  /// Total Score = (Sum of Contributions / Sum of Rated Weights) * 100
  static ScoreCalculationResult calculate(Map<AccessibilityCategory, double?> ratings) {
    double ratedWeightsSum = 0.0;
    double contributionsSum = 0.0;
    int ratedCount = 0;
    final contributions = <AccessibilityCategory, double>{};

    for (final category in AccessibilityCategory.values) {
      final rating = ratings[category];
      if (rating != null && rating > 0) {
        // Clamp rating to valid [1.0, 5.0] range
        final clampedRating = rating.clamp(1.0, 5.0);
        final contribution = category.weight * (clampedRating / 5.0);
        contributions[category] = contribution;
        contributionsSum += contribution;
        ratedWeightsSum += category.weight;
        ratedCount++;
      }
    }

    final totalCategories = AccessibilityCategory.values.length;
    final coveragePercentage = (ratedWeightsSum * 100).clamp(0.0, 100.0);

    if (ratedCount == 0 || ratedWeightsSum == 0) {
      return ScoreCalculationResult(
        score: null,
        coveragePercentage: 0.0,
        ratedCategoriesCount: 0,
        totalCategoriesCount: totalCategories,
        contributions: const {},
      );
    }

    // Normalized to 100 using the weights of rated categories only
    final normalizedScore = (contributionsSum / ratedWeightsSum) * 100.0;
    final clampedScore = normalizedScore.clamp(0.0, 100.0);

    return ScoreCalculationResult(
      score: clampedScore,
      coveragePercentage: coveragePercentage,
      ratedCategoriesCount: ratedCount,
      totalCategoriesCount: totalCategories,
      contributions: contributions,
    );
  }
}
