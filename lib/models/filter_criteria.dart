import 'place.dart';
import 'facility_status.dart';

enum SortOption {
  highestScore('Highest Score', 'Ranks by highest accessibility score'),
  mostRecent('Most Recent', 'Ranks by latest verified/reported date'),
  nearest('Nearest', 'Ranks by distance from current location');

  final String label;
  final String description;
  const SortOption(this.label, this.description);
}

class FilterCriteria {
  final String searchQuery;
  final String selectedCategory; // 'All' or specific category
  final bool stepFreeRequired;
  final bool workingLiftRequired;
  final bool accessibleWashroomRequired;
  final bool seatingRequired;
  final bool clearWayfindingRequired;
  final bool onlyConfirmedAccessible; // If true, strictly excludes Unknowns
  final SortOption sortOption;

  const FilterCriteria({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.stepFreeRequired = false,
    this.workingLiftRequired = false,
    this.accessibleWashroomRequired = false,
    this.seatingRequired = false,
    this.clearWayfindingRequired = false,
    this.onlyConfirmedAccessible = false,
    this.sortOption = SortOption.highestScore,
  });

  int get activeFiltersCount {
    int count = 0;
    if (selectedCategory != 'All') count++;
    if (stepFreeRequired) count++;
    if (workingLiftRequired) count++;
    if (accessibleWashroomRequired) count++;
    if (seatingRequired) count++;
    if (clearWayfindingRequired) count++;
    if (onlyConfirmedAccessible) count++;
    return count;
  }

  bool get hasActiveRequirements =>
      stepFreeRequired ||
      workingLiftRequired ||
      accessibleWashroomRequired ||
      seatingRequired ||
      clearWayfindingRequired ||
      onlyConfirmedAccessible;

  FilterCriteria copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool? stepFreeRequired,
    bool? workingLiftRequired,
    bool? accessibleWashroomRequired,
    bool? seatingRequired,
    bool? clearWayfindingRequired,
    bool? onlyConfirmedAccessible,
    SortOption? sortOption,
  }) {
    return FilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      stepFreeRequired: stepFreeRequired ?? this.stepFreeRequired,
      workingLiftRequired: workingLiftRequired ?? this.workingLiftRequired,
      accessibleWashroomRequired:
          accessibleWashroomRequired ?? this.accessibleWashroomRequired,
      seatingRequired: seatingRequired ?? this.seatingRequired,
      clearWayfindingRequired:
          clearWayfindingRequired ?? this.clearWayfindingRequired,
      onlyConfirmedAccessible:
          onlyConfirmedAccessible ?? this.onlyConfirmedAccessible,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// Evaluates whether a place satisfies this filter criteria
  bool matches(Place place) {
    // 1. Text Search query
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      final matchName = place.name.toLowerCase().contains(query);
      final matchAddress = place.address.toLowerCase().contains(query);
      final matchLocality = place.locality.toLowerCase().contains(query);
      final matchCategory = place.category.toLowerCase().contains(query);
      if (!matchName && !matchAddress && !matchLocality && !matchCategory) {
        return false;
      }
    }

    // 2. Category Filter
    if (selectedCategory != 'All') {
      if (place.category.toLowerCase() != selectedCategory.toLowerCase()) {
        return false;
      }
    }

    // 3. Facility Requirements
    if (stepFreeRequired && !_passesFacilityCheck(place.stepFreeEntry)) {
      return false;
    }
    if (workingLiftRequired && !_passesFacilityCheck(place.workingLift)) {
      return false;
    }
    if (accessibleWashroomRequired && !_passesFacilityCheck(place.accessibleWashroom)) {
      return false;
    }
    if (seatingRequired && !_passesFacilityCheck(place.seatingAvailable)) {
      return false;
    }
    if (clearWayfindingRequired && !_passesFacilityCheck(place.clearSignage)) {
      return false;
    }

    return true;
  }

  bool _passesFacilityCheck(FacilityStatus status) {
    if (status == FacilityStatus.available) {
      return true;
    }
    if (status == FacilityStatus.unavailable) {
      return false; // Confirmed unavailable is always excluded
    }
    // status == FacilityStatus.unknown
    // If onlyConfirmedAccessible is requested, exclude unknown
    if (onlyConfirmedAccessible) {
      return false;
    }
    // Otherwise allow unconfirmed (it will be labeled as unconfirmed in UI)
    return true;
  }

  List<Place> applyAndSort(List<Place> places) {
    final filtered = places.where(matches).toList();

    filtered.sort((a, b) {
      switch (sortOption) {
        case SortOption.highestScore:
          final scoreA = a.overallScore ?? -1;
          final scoreB = b.overallScore ?? -1;
          return scoreB.compareTo(scoreA);

        case SortOption.mostRecent:
          final dateA = a.lastReportedDate ?? DateTime(2000);
          final dateB = b.lastReportedDate ?? DateTime(2000);
          return dateB.compareTo(dateA);

        case SortOption.nearest:
          final distA = a.distanceKm ?? 9999.0;
          final distB = b.distanceKm ?? 9999.0;
          return distA.compareTo(distB);
      }
    });

    return filtered;
  }
}
