import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/place.dart';
import '../models/review.dart';
import '../models/accessibility_category.dart';
import '../services/place_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/score_breakdown_card.dart';
import '../widgets/ai_summary_card.dart';
import '../widgets/facility_indicator_chip.dart';
import 'feedback_screen.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;
  final PlaceRepository repository;
  final ValueChanged<String>? onAddFeedback;

  const PlaceDetailsScreen({
    super.key,
    required this.placeId,
    required this.repository,
    this.onAddFeedback,
  });

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool _isRegeneratingAi = false;

  void _openAddFeedbackForm(Place place) {
    if (widget.onAddFeedback != null) {
      widget.onAddFeedback!(place.id);
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackScreen(
            repository: widget.repository,
            initialPlaceId: place.id,
          ),
        ),
      );
    }
  }

  Future<void> _regenerateAiSummary(Place place) async {
    setState(() {
      _isRegeneratingAi = true;
    });

    try {
      // Simulate/trigger regeneration of AI summary
      await widget.repository.submitReview(
        Review(
          id: 'temp_refresh_${DateTime.now().millisecondsSinceEpoch}',
          placeId: place.id,
          reviewerName: 'System Re-evaluator',
          reviewerTag: 'Automated Audit',
          ratings: const {},
          facilityObservations: const {},
          comment: '',
          visitDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Graceful error ignore
    } finally {
      if (mounted) {
        setState(() {
          _isRegeneratingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final place = widget.repository.getPlaceById(widget.placeId);
        if (place == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Place Report')),
            body: const Center(child: Text('Place not found.')),
          );
        }

        final isSaved = place.isSaved;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              place.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: isSaved ? AppTheme.primaryTeal : AppTheme.textDarkNavy,
                ),
                tooltip: isSaved ? 'Remove from saved' : 'Save place',
                onPressed: () => widget.repository.toggleBookmark(place.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share accessibility report',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Accessibility link copied for ${place.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: _buildBottomActionBar(place),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Place Header Info Card
                _buildPlaceHeaderCard(place),

                const SizedBox(height: 16),

                // Comprehensive Score Breakdown & 5 Categories Card
                ScoreBreakdownCard(place: place),

                const SizedBox(height: 16),

                // Structured Facility Matrix
                _buildFacilityMatrixCard(place),

                const SizedBox(height: 16),

                // AI-Generated Community Feedback Summary
                AiSummaryCard(
                  aiSummary: place.aiSummary,
                  isRegenerating: _isRegeneratingAi,
                  onRegenerate: () => _regenerateAiSummary(place),
                ),

                const SizedBox(height: 24),

                // Community Feedback Section
                _buildCommunityFeedbackSection(place),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceHeaderCard(Place place) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlueLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    place.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: place.verificationStatus == VerificationType.independentlyVerified
                        ? AppTheme.statusGreenLight
                        : AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        place.verificationStatus == VerificationType.independentlyVerified
                            ? Icons.verified_rounded
                            : Icons.people_outline_rounded,
                        size: 13,
                        color: place.verificationStatus == VerificationType.independentlyVerified
                            ? AppTheme.statusGreen
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.verificationStatus.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: place.verificationStatus == VerificationType.independentlyVerified
                              ? AppTheme.statusGreen
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDarkNavy,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${place.address}, ${place.locality}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
            if (place.lastReportedDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.history_rounded, size: 14, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text(
                    'Latest community report: ${DateFormat('MMMM d, yyyy').format(place.lastReportedDate!)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityMatrixCard(Place place) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Structured Facility Status Matrix',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDarkNavy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Explicit on-site accessibility equipment status:',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FacilityIndicatorChip(
                  label: 'Step-Free Entrance',
                  status: place.stepFreeEntry,
                  facilityIcon: Icons.accessible_rounded,
                ),
                FacilityIndicatorChip(
                  label: 'Working Elevator',
                  status: place.workingLift,
                  facilityIcon: Icons.elevator_rounded,
                ),
                FacilityIndicatorChip(
                  label: 'Accessible Restroom',
                  status: place.accessibleWashroom,
                  facilityIcon: Icons.wc_rounded,
                ),
                FacilityIndicatorChip(
                  label: 'Corridor Seating',
                  status: place.seatingAvailable,
                  facilityIcon: Icons.chair_rounded,
                ),
                FacilityIndicatorChip(
                  label: 'Wayfinding & Braille',
                  status: place.clearSignage,
                  facilityIcon: Icons.signpost_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityFeedbackSection(Place place) {
    final reviews = place.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                  ),
                ),
                Text(
                  '${reviews.length} ${reviews.length == 1 ? "visitor report" : "visitor reports"} recorded',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openAddFeedbackForm(place),
              icon: const Icon(Icons.rate_review_rounded, size: 16),
              label: const Text('Add Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                minimumSize: const Size(120, 38),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.comment_outlined, size: 36, color: AppTheme.textMuted),
                  const SizedBox(height: 8),
                  const Text(
                    'No community reviews yet',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Be the first to share your accessibility observations.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          ...reviews.map((r) => _buildReviewCard(r)),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final dateStr = DateFormat('MMM d, yyyy').format(review.visitDate);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryTealLight,
                  child: Text(
                    review.reviewerName.isNotEmpty ? review.reviewerName[0] : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTealDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.reviewerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDarkNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (review.isVerifiedVolunteer) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppTheme.statusGreen,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        review.reviewerTag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Visited $dateStr',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),

            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textDarkNavy,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Rating pills for rated categories
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: AccessibilityCategory.values
                  .where((c) => review.ratings[c] != null)
                  .map((c) {
                final rating = review.ratings[c]!;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        c.shortTitle,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)}★',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(Place place) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(top: BorderSide(color: AppTheme.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Bookmark Button
            OutlinedButton(
              onPressed: () => widget.repository.toggleBookmark(place.id),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Icon(
                place.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: place.isSaved ? AppTheme.primaryTeal : AppTheme.textDarkNavy,
              ),
            ),
            const SizedBox(width: 12),
            // Primary Feedback Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openAddFeedbackForm(place),
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text(
                  'Submit Accessibility Review',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
