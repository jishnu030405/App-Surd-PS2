import 'package:flutter_test/flutter_test.dart';
import 'package:accesspath/models/accessibility_category.dart';
import 'package:accesspath/utils/accessibility_score.dart';

void main() {
  group('AccessibilityScoreCalculator Tests', () {
    test('All 5 categories rated calculates exact weighted score out of 100', () {
      // Step-free: 5.0 (30% * 1.0 = 30)
      // Lifts: 4.0 (20% * 0.8 = 16)
      // Washrooms: 3.0 (20% * 0.6 = 12)
      // Seating: 4.0 (15% * 0.8 = 12)
      // Signage: 5.0 (15% * 1.0 = 15)
      // Expected sum: 30 + 16 + 12 + 12 + 15 = 85.0
      final ratings = {
        AccessibilityCategory.stepFreeAccess: 5.0,
        AccessibilityCategory.liftsAndRamps: 4.0,
        AccessibilityCategory.accessibleWashrooms: 3.0,
        AccessibilityCategory.seatingAvailability: 4.0,
        AccessibilityCategory.signageAndWayfinding: 5.0,
      };

      final result = AccessibilityScoreCalculator.calculate(ratings);

      expect(result.hasSufficientData, isTrue);
      expect(result.score, closeTo(85.0, 0.01));
      expect(result.roundedScore, equals(85));
      expect(result.coveragePercentage, closeTo(100.0, 0.01));
      expect(result.ratedCategoriesCount, equals(5));
      expect(result.interpretationLabel, equals('Highly Accessible'));
    });

    test('Partial categories rated normalizes using weights of rated categories only', () {
      // Rated categories: Step-free (0.30) rating 5.0 -> contribution = 0.30
      // Lifts (0.20) rating 4.0 -> contribution = 0.16
      // Washrooms is Unknown (null)
      // Seating is Unknown (null)
      // Signage is Unknown (null)
      // Rated weights sum: 0.30 + 0.20 = 0.50 (Coverage = 50%)
      // Contributions sum: 0.30 + 0.16 = 0.46
      // Normalized Score: (0.46 / 0.50) * 100 = 92.0
      final ratings = {
        AccessibilityCategory.stepFreeAccess: 5.0,
        AccessibilityCategory.liftsAndRamps: 4.0,
        AccessibilityCategory.accessibleWashrooms: null,
        AccessibilityCategory.seatingAvailability: null,
        AccessibilityCategory.signageAndWayfinding: null,
      };

      final result = AccessibilityScoreCalculator.calculate(ratings);

      expect(result.hasSufficientData, isTrue);
      expect(result.score, closeTo(92.0, 0.01));
      expect(result.roundedScore, equals(92));
      expect(result.coveragePercentage, closeTo(50.0, 0.01));
      expect(result.ratedCategoriesCount, equals(2));
      expect(result.interpretationLabel, equals('Highly Accessible'));
    });

    test('Zero categories rated returns null score and Not Enough Info', () {
      final ratings = {
        AccessibilityCategory.stepFreeAccess: null,
        AccessibilityCategory.liftsAndRamps: null,
        AccessibilityCategory.accessibleWashrooms: null,
        AccessibilityCategory.seatingAvailability: null,
        AccessibilityCategory.signageAndWayfinding: null,
      };

      final result = AccessibilityScoreCalculator.calculate(ratings);

      expect(result.hasSufficientData, isFalse);
      expect(result.score, isNull);
      expect(result.coveragePercentage, equals(0.0));
      expect(result.ratedCategoriesCount, equals(0));
      expect(result.interpretationLabel, equals('Not Enough Info'));
    });

    test('Category weights sum to exactly 1.0 (100%)', () {
      double totalWeight = 0.0;
      for (final cat in AccessibilityCategory.values) {
        totalWeight += cat.weight;
      }
      expect(totalWeight, closeTo(1.0, 0.0001));
    });

    test('Ratings are clamped within valid 1.0 to 5.0 range', () {
      final ratings = {
        AccessibilityCategory.stepFreeAccess: 6.0, // Should clamp to 5.0
        AccessibilityCategory.liftsAndRamps: 5.0,
        AccessibilityCategory.accessibleWashrooms: 5.0,
        AccessibilityCategory.seatingAvailability: 5.0,
        AccessibilityCategory.signageAndWayfinding: 5.0,
      };

      final result = AccessibilityScoreCalculator.calculate(ratings);
      expect(result.score, closeTo(100.0, 0.01));
    });

    test('Score interpretation thresholds map accurately', () {
      // 85-100: Highly Accessible
      final r85 = AccessibilityScoreCalculator.calculate({
        AccessibilityCategory.stepFreeAccess: 4.25,
        AccessibilityCategory.liftsAndRamps: 4.25,
        AccessibilityCategory.accessibleWashrooms: 4.25,
        AccessibilityCategory.seatingAvailability: 4.25,
        AccessibilityCategory.signageAndWayfinding: 4.25,
      });
      expect(r85.interpretationLabel, equals('Highly Accessible'));

      // 65-84: Substantially Accessible
      final r70 = AccessibilityScoreCalculator.calculate({
        AccessibilityCategory.stepFreeAccess: 3.5,
        AccessibilityCategory.liftsAndRamps: 3.5,
        AccessibilityCategory.accessibleWashrooms: 3.5,
        AccessibilityCategory.seatingAvailability: 3.5,
        AccessibilityCategory.signageAndWayfinding: 3.5,
      });
      expect(r70.interpretationLabel, equals('Substantially Accessible'));

      // 45-64: Partially Accessible
      final r50 = AccessibilityScoreCalculator.calculate({
        AccessibilityCategory.stepFreeAccess: 2.5,
        AccessibilityCategory.liftsAndRamps: 2.5,
        AccessibilityCategory.accessibleWashrooms: 2.5,
        AccessibilityCategory.seatingAvailability: 2.5,
        AccessibilityCategory.signageAndWayfinding: 2.5,
      });
      expect(r50.interpretationLabel, equals('Partially Accessible'));

      // <45: Significant Barriers
      final r30 = AccessibilityScoreCalculator.calculate({
        AccessibilityCategory.stepFreeAccess: 1.5,
        AccessibilityCategory.liftsAndRamps: 1.5,
        AccessibilityCategory.accessibleWashrooms: 1.5,
        AccessibilityCategory.seatingAvailability: 1.5,
        AccessibilityCategory.signageAndWayfinding: 1.5,
      });
      expect(r30.interpretationLabel, equals('Significant Barriers'));
    });
  });
}
