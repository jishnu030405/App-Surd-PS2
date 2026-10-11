import 'accessibility_category.dart';
import 'facility_status.dart';
import 'review.dart';
import 'ai_summary.dart';
import '../utils/accessibility_score.dart';

enum VerificationType {
  independentlyVerified('Independently Verified'),
  communityReported('Community Reported'),
  unconfirmed('Unverified Sample');

  final String label;
  const VerificationType(this.label);
}

class Place {
  final String id;
  final String name;
  final String category; // 'Hospitals', 'Colleges', 'Shopping', 'Transport', 'Public Offices'
  final String address;
  final String locality;
  final double? distanceKm;
  final double latitude;
  final double longitude;
  final Map<AccessibilityCategory, double?> categoryRatings;
  final Map<AccessibilityCategory, String> categoryNotes;
  final Map<String, FacilityStatus> facilityStatuses;
  final VerificationType verificationStatus;
  final DateTime? lastReportedDate;
  final DateTime? lastVerifiedDate;
  final List<Review> reviews;
  final AiSummary? aiSummary;
  final bool isSaved;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.locality,
    this.distanceKm,
    required this.latitude,
    required this.longitude,
    required this.categoryRatings,
    required this.categoryNotes,
    required this.facilityStatuses,
    required this.verificationStatus,
    this.lastReportedDate,
    this.lastVerifiedDate,
    required this.reviews,
    this.aiSummary,
    this.isSaved = false,
  });

  ScoreCalculationResult get scoreResult {
    return AccessibilityScoreCalculator.calculate(categoryRatings);
  }

  double? get overallScore => scoreResult.score;
  int get roundedScore => scoreResult.roundedScore;
  double get coveragePercentage => scoreResult.coveragePercentage;
  String get statusLabel => scoreResult.interpretationLabel;
  String get shortStatus => scoreResult.shortStatus;

  FacilityStatus get stepFreeEntry => facilityStatuses['stepFreeEntry'] ?? FacilityStatus.unknown;
  FacilityStatus get workingLift => facilityStatuses['workingLift'] ?? FacilityStatus.unknown;
  FacilityStatus get accessibleWashroom => facilityStatuses['accessibleWashroom'] ?? FacilityStatus.unknown;
  FacilityStatus get seatingAvailable => facilityStatuses['seatingAvailable'] ?? FacilityStatus.unknown;
  FacilityStatus get clearSignage => facilityStatuses['clearSignage'] ?? FacilityStatus.unknown;

  Place copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? locality,
    double? distanceKm,
    double? latitude,
    double? longitude,
    Map<AccessibilityCategory, double?>? categoryRatings,
    Map<AccessibilityCategory, String>? categoryNotes,
    Map<String, FacilityStatus>? facilityStatuses,
    VerificationType? verificationStatus,
    DateTime? lastReportedDate,
    DateTime? lastVerifiedDate,
    List<Review>? reviews,
    AiSummary? aiSummary,
    bool? isSaved,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      locality: locality ?? this.locality,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      categoryNotes: categoryNotes ?? this.categoryNotes,
      facilityStatuses: facilityStatuses ?? this.facilityStatuses,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      lastReportedDate: lastReportedDate ?? this.lastReportedDate,
      lastVerifiedDate: lastVerifiedDate ?? this.lastVerifiedDate,
      reviews: reviews ?? this.reviews,
      aiSummary: aiSummary ?? this.aiSummary,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'locality': locality,
      'distanceKm': distanceKm,
      'latitude': latitude,
      'longitude': longitude,
      'categoryRatings': categoryRatings.map((k, v) => MapEntry(k.id, v)),
      'categoryNotes': categoryNotes.map((k, v) => MapEntry(k.id, v)),
      'facilityStatuses': facilityStatuses.map((k, v) => MapEntry(k, v.name)),
      'verificationStatus': verificationStatus.name,
      'lastReportedDate': lastReportedDate?.toIso8601String(),
      'lastVerifiedDate': lastVerifiedDate?.toIso8601String(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'aiSummary': aiSummary?.toJson(),
      'isSaved': isSaved,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    final rawRatings = json['categoryRatings'] as Map<String, dynamic>? ?? {};
    final parsedRatings = <AccessibilityCategory, double?>{};
    for (final cat in AccessibilityCategory.values) {
      if (rawRatings.containsKey(cat.id)) {
        parsedRatings[cat] = (rawRatings[cat.id] as num?)?.toDouble();
      } else {
        parsedRatings[cat] = null;
      }
    }

    final rawNotes = json['categoryNotes'] as Map<String, dynamic>? ?? {};
    final parsedNotes = <AccessibilityCategory, String>{};
    for (final cat in AccessibilityCategory.values) {
      if (rawNotes.containsKey(cat.id)) {
        parsedNotes[cat] = rawNotes[cat.id] as String;
      }
    }

    final rawFacilities = json['facilityStatuses'] as Map<String, dynamic>? ?? {};
    final parsedFacilities = <String, FacilityStatus>{};
    rawFacilities.forEach((key, val) {
      parsedFacilities[key] = FacilityStatus.fromString(val as String?);
    });

    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final parsedReviews = rawReviews
        .map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList();

    VerificationType verification = VerificationType.communityReported;
    final verStr = json['verificationStatus'] as String?;
    if (verStr == VerificationType.independentlyVerified.name) {
      verification = VerificationType.independentlyVerified;
    } else if (verStr == VerificationType.unconfirmed.name) {
      verification = VerificationType.unconfirmed;
    }

    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      locality: json['locality'] as String,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      categoryRatings: parsedRatings,
      categoryNotes: parsedNotes,
      facilityStatuses: parsedFacilities,
      verificationStatus: verification,
      lastReportedDate: json['lastReportedDate'] != null
          ? DateTime.tryParse(json['lastReportedDate'] as String)
          : null,
      lastVerifiedDate: json['lastVerifiedDate'] != null
          ? DateTime.tryParse(json['lastVerifiedDate'] as String)
          : null,
      reviews: parsedReviews,
      aiSummary: json['aiSummary'] != null
          ? AiSummary.fromJson(json['aiSummary'] as Map<String, dynamic>)
          : null,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }
}
