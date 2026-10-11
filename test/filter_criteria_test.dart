import 'package:flutter_test/flutter_test.dart';
import 'package:accesspath/models/filter_criteria.dart';
import 'package:accesspath/models/facility_status.dart';
import 'package:accesspath/utils/sample_data.dart';

void main() {
  group('FilterCriteria Tests', () {
    final samplePlaces = SampleData.getSamplePlaces();

    test('Category filter isolates specific category places', () {
      const criteria = FilterCriteria(selectedCategory: 'Hospitals');
      final filtered = criteria.applyAndSort(samplePlaces);

      expect(filtered.isNotEmpty, isTrue);
      for (final place in filtered) {
        expect(place.category, equals('Hospitals'));
      }
    });

    test('Search query matches case-insensitive name or address', () {
      const criteria = FilterCriteria(searchQuery: 'st. jude');
      final filtered = criteria.applyAndSort(samplePlaces);

      expect(filtered.length, equals(1));
      expect(filtered.first.name, contains('St. Jude'));
    });

    test('Step-free requirement excludes confirmed unavailable places', () {
      const criteria = FilterCriteria(stepFreeRequired: true);
      final filtered = criteria.applyAndSort(samplePlaces);

      for (final place in filtered) {
        expect(place.stepFreeEntry, isNot(equals(FacilityStatus.unavailable)));
      }
    });

    test('Strict mode onlyConfirmedAccessible excludes unknown facilities', () {
      const strictCriteria = FilterCriteria(
        accessibleWashroomRequired: true,
        onlyConfirmedAccessible: true,
      );
      final filtered = strictCriteria.applyAndSort(samplePlaces);

      for (final place in filtered) {
        expect(place.accessibleWashroom, equals(FacilityStatus.available));
      }

      // Check that place with unknown washroom (Heritage Museum) is excluded
      final hasMuseum = filtered.any((p) => p.id == 'place_heritage_museum');
      expect(hasMuseum, isFalse);
    });

    test('Sort by highest score orders descending by accessibility score', () {
      const criteria = FilterCriteria(sortOption: SortOption.highestScore);
      final sorted = criteria.applyAndSort(samplePlaces);

      for (int i = 0; i < sorted.length - 1; i++) {
        final scoreA = sorted[i].overallScore ?? -1;
        final scoreB = sorted[i + 1].overallScore ?? -1;
        expect(scoreA >= scoreB, isTrue);
      }
    });

    test('Sort by nearest orders ascending by distance in km', () {
      const criteria = FilterCriteria(sortOption: SortOption.nearest);
      final sorted = criteria.applyAndSort(samplePlaces);

      for (int i = 0; i < sorted.length - 1; i++) {
        final distA = sorted[i].distanceKm ?? 9999.0;
        final distB = sorted[i + 1].distanceKm ?? 9999.0;
        expect(distA <= distB, isTrue);
      }
    });

    test('Active filters count updates accurately', () {
      const defaultCriteria = FilterCriteria();
      expect(defaultCriteria.activeFiltersCount, equals(0));

      const activeCriteria = FilterCriteria(
        selectedCategory: 'Transport',
        stepFreeRequired: true,
        workingLiftRequired: true,
        onlyConfirmedAccessible: true,
      );
      expect(activeCriteria.activeFiltersCount, equals(4));
    });
  });
}
