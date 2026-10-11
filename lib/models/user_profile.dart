class UserProfile {
  final String name;
  final String role;
  final String personaPreset;
  final int reviewsSubmittedCount;
  final int savedPlacesCount;
  final bool preferredStepFree;
  final bool preferredLift;
  final bool preferredWashroom;
  final bool preferredSeating;
  final bool preferredWayfinding;

  const UserProfile({
    this.name = 'Alex Johnson',
    this.role = 'Community Accessibility Scout',
    this.personaPreset = 'Wheelchair User',
    this.reviewsSubmittedCount = 4,
    this.savedPlacesCount = 3,
    this.preferredStepFree = true,
    this.preferredLift = true,
    this.preferredWashroom = true,
    this.preferredSeating = false,
    this.preferredWayfinding = false,
  });

  UserProfile copyWith({
    String? name,
    String? role,
    String? personaPreset,
    int? reviewsSubmittedCount,
    int? savedPlacesCount,
    bool? preferredStepFree,
    bool? preferredLift,
    bool? preferredWashroom,
    bool? preferredSeating,
    bool? preferredWayfinding,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      personaPreset: personaPreset ?? this.personaPreset,
      reviewsSubmittedCount: reviewsSubmittedCount ?? this.reviewsSubmittedCount,
      savedPlacesCount: savedPlacesCount ?? this.savedPlacesCount,
      preferredStepFree: preferredStepFree ?? this.preferredStepFree,
      preferredLift: preferredLift ?? this.preferredLift,
      preferredWashroom: preferredWashroom ?? this.preferredWashroom,
      preferredSeating: preferredSeating ?? this.preferredSeating,
      preferredWayfinding: preferredWayfinding ?? this.preferredWayfinding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'personaPreset': personaPreset,
      'reviewsSubmittedCount': reviewsSubmittedCount,
      'savedPlacesCount': savedPlacesCount,
      'preferredStepFree': preferredStepFree,
      'preferredLift': preferredLift,
      'preferredWashroom': preferredWashroom,
      'preferredSeating': preferredSeating,
      'preferredWayfinding': preferredWayfinding,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Alex Johnson',
      role: json['role'] as String? ?? 'Community Accessibility Scout',
      personaPreset: json['personaPreset'] as String? ?? 'Wheelchair User',
      reviewsSubmittedCount: (json['reviewsSubmittedCount'] as num?)?.toInt() ?? 0,
      savedPlacesCount: (json['savedPlacesCount'] as num?)?.toInt() ?? 0,
      preferredStepFree: json['preferredStepFree'] as bool? ?? true,
      preferredLift: json['preferredLift'] as bool? ?? true,
      preferredWashroom: json['preferredWashroom'] as bool? ?? true,
      preferredSeating: json['preferredSeating'] as bool? ?? false,
      preferredWayfinding: json['preferredWayfinding'] as bool? ?? false,
    );
  }
}
