import 'package:flutter/material.dart';
import '../models/place.dart';
import '../models/review.dart';
import '../models/accessibility_category.dart';
import '../models/facility_status.dart';
import '../models/user_profile.dart';
import '../utils/sample_data.dart';
import 'storage_service.dart';
import 'ai_summary_service.dart';

class PlaceRepository extends ChangeNotifier {
  final StorageService storageService;
  final AiSummaryService aiSummaryService;

  List<Place> _places = [];
  Set<String> _bookmarkedIds = {};
  UserProfile _userProfile = const UserProfile();
  bool _isLoading = true;

  PlaceRepository({
    required this.storageService,
    required this.aiSummaryService,
  });

  List<Place> get places => List.unmodifiable(_places);
  List<Place> get savedPlaces => _places.where((p) => _bookmarkedIds.contains(p.id)).toList();
  Set<String> get bookmarkedIds => Set.unmodifiable(_bookmarkedIds);
  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _bookmarkedIds = storageService.loadBookmarkedIds();
    _userProfile = storageService.loadUserProfile();

    // Load places from storage or fall back to rich sample data
    final persistedPlaces = storageService.loadCustomPlaces();
    if (persistedPlaces != null && persistedPlaces.isNotEmpty) {
      _places = persistedPlaces;
    } else {
      _places = SampleData.getSamplePlaces();
    }

    // Apply bookmarks
    _places = _places.map((place) {
      final isSaved = _bookmarkedIds.contains(place.id) || place.isSaved;
      if (isSaved) {
        _bookmarkedIds.add(place.id);
      }
      return place.copyWith(isSaved: isSaved);
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Place? getPlaceById(String id) {
    try {
      return _places.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleBookmark(String placeId) async {
    if (_bookmarkedIds.contains(placeId)) {
      _bookmarkedIds.remove(placeId);
    } else {
      _bookmarkedIds.add(placeId);
    }

    _places = _places.map((p) {
      if (p.id == placeId) {
        return p.copyWith(isSaved: _bookmarkedIds.contains(placeId));
      }
      return p;
    }).toList();

    await storageService.saveBookmarkedIds(_bookmarkedIds);
    _userProfile = _userProfile.copyWith(savedPlacesCount: _bookmarkedIds.length);
    await storageService.saveUserProfile(_userProfile);
    notifyListeners();
  }

  /// Submits an accessibility feedback review:
  /// 1. Appends review to place
  /// 2. Recalculates category ratings
  /// 3. Recalculates accessibility score
  /// 4. Updates facility statuses
  /// 5. Regenerates structured AI summary
  /// 6. Persists data and notifies listeners
  Future<Place> submitReview(Review review) async {
    final index = _places.indexWhere((p) => p.id == review.placeId);
    if (index == -1) {
      throw Exception('Place with id ${review.placeId} not found.');
    }

    final currentPlace = _places[index];
    final updatedReviews = [review, ...currentPlace.reviews];

    // Recalculate average category ratings
    final newCategoryRatings = <AccessibilityCategory, double?>{};
    for (final cat in AccessibilityCategory.values) {
      final ratingsList = <double>[];
      for (final r in updatedReviews) {
        final val = r.ratings[cat];
        if (val != null && val > 0) {
          ratingsList.add(val);
        }
      }
      if (ratingsList.isNotEmpty) {
        final avg = ratingsList.reduce((a, b) => a + b) / ratingsList.length;
        // round to 1 decimal place
        newCategoryRatings[cat] = double.parse(avg.toStringAsFixed(1));
      } else {
        newCategoryRatings[cat] = currentPlace.categoryRatings[cat];
      }
    }

    // Update facility statuses based on observations
    final updatedFacilities = Map<String, FacilityStatus>.from(currentPlace.facilityStatuses);
    review.facilityObservations.forEach((key, status) {
      if (status != FacilityStatus.unknown) {
        updatedFacilities[key] = status;
      }
    });

    Place intermediatePlace = currentPlace.copyWith(
      reviews: updatedReviews,
      categoryRatings: newCategoryRatings,
      facilityStatuses: updatedFacilities,
      lastReportedDate: DateTime.now(),
    );

    // Refresh AI summary based on updated reviews and data
    final newSummary = await aiSummaryService.generateSummary(intermediatePlace);
    final finalUpdatedPlace = intermediatePlace.copyWith(aiSummary: newSummary);

    _places[index] = finalUpdatedPlace;

    // Update user profile counters
    _userProfile = _userProfile.copyWith(
      reviewsSubmittedCount: _userProfile.reviewsSubmittedCount + 1,
    );

    await storageService.saveCustomPlaces(_places);
    await storageService.saveUserProfile(_userProfile);
    notifyListeners();

    return finalUpdatedPlace;
  }

  /// Creates a new place report
  Future<Place> addPlace(Place newPlace) async {
    final summary = await aiSummaryService.generateSummary(newPlace);
    final placeWithSummary = newPlace.copyWith(aiSummary: summary);

    _places.insert(0, placeWithSummary);
    await storageService.saveCustomPlaces(_places);
    notifyListeners();
    return placeWithSummary;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await storageService.saveUserProfile(profile);
    notifyListeners();
  }

  /// Resets data back to pristine demo state
  Future<void> resetToDemoData() async {
    await storageService.clearAll();
    _places = SampleData.getSamplePlaces();
    _bookmarkedIds = {'place_st_jude_hospital', 'place_city_metro'};
    _userProfile = const UserProfile(
      name: 'Alex Johnson',
      role: 'Community Accessibility Scout',
      personaPreset: 'Wheelchair User',
      reviewsSubmittedCount: 4,
      savedPlacesCount: 2,
    );

    _places = _places.map((p) => p.copyWith(isSaved: _bookmarkedIds.contains(p.id))).toList();
    await storageService.saveBookmarkedIds(_bookmarkedIds);
    await storageService.saveCustomPlaces(_places);
    await storageService.saveUserProfile(_userProfile);
    notifyListeners();
  }
}
