import 'accessibility_category.dart';
import 'facility_status.dart';

class Review {
  final String id;
  final String placeId;
  final String reviewerName;
  final String reviewerTag;
  final Map<AccessibilityCategory, double?> ratings;
  final Map<String, FacilityStatus> facilityObservations;
  final String comment;
  final DateTime visitDate;
  final DateTime createdAt;
  final bool isVerifiedVolunteer;

  const Review({
    required this.id,
    required this.placeId,
    required this.reviewerName,
    required this.reviewerTag,
    required this.ratings,
    required this.facilityObservations,
    required this.comment,
    required this.visitDate,
    required this.createdAt,
    this.isVerifiedVolunteer = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'reviewerName': reviewerName,
      'reviewerTag': reviewerTag,
      'ratings': ratings.map((k, v) => MapEntry(k.id, v)),
      'facilityObservations': facilityObservations.map((k, v) => MapEntry(k, v.name)),
      'comment': comment,
      'visitDate': visitDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isVerifiedVolunteer': isVerifiedVolunteer,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    final rawRatings = json['ratings'] as Map<String, dynamic>? ?? {};
    final parsedRatings = <AccessibilityCategory, double?>{};
    for (final cat in AccessibilityCategory.values) {
      if (rawRatings.containsKey(cat.id)) {
        parsedRatings[cat] = (rawRatings[cat.id] as num?)?.toDouble();
      } else {
        parsedRatings[cat] = null;
      }
    }

    final rawFacilities = json['facilityObservations'] as Map<String, dynamic>? ?? {};
    final parsedFacilities = <String, FacilityStatus>{};
    rawFacilities.forEach((key, val) {
      parsedFacilities[key] = FacilityStatus.fromString(val as String?);
    });

    return Review(
      id: json['id'] as String? ?? UniqueKey().toString(),
      placeId: json['placeId'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? 'Anonymous Visitor',
      reviewerTag: json['reviewerTag'] as String? ?? 'Community Contributor',
      ratings: parsedRatings,
      facilityObservations: parsedFacilities,
      comment: json['comment'] as String? ?? '',
      visitDate: json['visitDate'] != null
          ? DateTime.tryParse(json['visitDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isVerifiedVolunteer: json['isVerifiedVolunteer'] as bool? ?? false,
    );
  }
}

class UniqueKey {
  static int _counter = 0;
  @override
  String toString() => 'rev_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
}
