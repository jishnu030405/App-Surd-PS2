import 'package:flutter/material.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import 'accessibility_badge.dart';
import 'facility_indicator_chip.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onToggleBookmark,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hospitals':
        return Icons.local_hospital_rounded;
      case 'colleges':
        return Icons.school_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'transport':
        return Icons.directions_subway_rounded;
      case 'public offices':
        return Icons.account_balance_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreResult = place.scoreResult;

    return Semantics(
      label: '${place.name}, ${place.category}, in ${place.locality}. '
          'Score: ${scoreResult.hasSufficientData ? "${scoreResult.roundedScore} out of 100" : "Unverified"}. '
          'Step-free: ${place.stepFreeEntry.displayName}. '
          'Lift: ${place.workingLift.displayName}. '
          'Washroom: ${place.accessibleWashroom.displayName}.',
      button: true,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category tag, distance & bookmark button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBlueLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(place.category),
                            size: 14,
                            color: AppTheme.secondaryBlue,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            place.category,
                            style: const TextStyle(
                              color: AppTheme.secondaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (place.distanceKm != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 12,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${place.distanceKm!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Accessibility Score Badge (compact in header)
                    AccessibilityBadge(
                      scoreResult: scoreResult,
                      compact: true,
                      showCoverage: false,
                    ),
                    const SizedBox(width: 4),
                    // Bookmark toggle
                    IconButton(
                      icon: Icon(
                        place.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: place.isSaved ? AppTheme.primaryTeal : AppTheme.textMuted,
                        size: 22,
                      ),
                      tooltip: place.isSaved ? 'Remove bookmark' : 'Save place',
                      onPressed: onToggleBookmark,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Place Title
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 4),

                // Address & Locality
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Key Facility Indicators (3 core indicators)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    FacilityIndicatorChip(
                      label: 'Step-Free',
                      status: place.stepFreeEntry,
                      facilityIcon: Icons.accessible_rounded,
                      compact: true,
                    ),
                    FacilityIndicatorChip(
                      label: 'Lift',
                      status: place.workingLift,
                      facilityIcon: Icons.elevator_rounded,
                      compact: true,
                    ),
                    FacilityIndicatorChip(
                      label: 'Washroom',
                      status: place.accessibleWashroom,
                      facilityIcon: Icons.wc_rounded,
                      compact: true,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 10),

                // Bottom row: Reviews count, last reported, and view arrow
                Row(
                  children: [
                    Icon(
                      place.verificationStatus == VerificationType.independentlyVerified
                          ? Icons.verified_rounded
                          : Icons.people_outline_rounded,
                      size: 15,
                      color: place.verificationStatus == VerificationType.independentlyVerified
                          ? AppTheme.statusGreen
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${place.reviews.length} ${place.reviews.length == 1 ? 'review' : 'reviews'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDarkNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.borderLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.verificationStatus.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: place.verificationStatus == VerificationType.independentlyVerified
                              ? AppTheme.statusGreen
                              : AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View Report',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppTheme.primaryTeal,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
