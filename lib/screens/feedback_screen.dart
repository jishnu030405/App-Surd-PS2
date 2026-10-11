import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../models/accessibility_category.dart';
import '../models/facility_status.dart';
import '../services/place_repository.dart';
import '../theme/app_theme.dart';
import 'place_details_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final PlaceRepository repository;
  final String? initialPlaceId;

  const FeedbackScreen({
    super.key,
    required this.repository,
    this.initialPlaceId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPlaceId;
  late DateTime _visitDate;
  late TextEditingController _commentController;
  late TextEditingController _reviewerNameController;
  String _selectedReviewerTag = 'Wheelchair User';

  // Ratings for the 5 categories (1.0 to 5.0, or null if Unknown)
  final Map<AccessibilityCategory, double?> _categoryRatings = {
    AccessibilityCategory.stepFreeAccess: 4.0,
    AccessibilityCategory.liftsAndRamps: 4.0,
    AccessibilityCategory.accessibleWashrooms: 4.0,
    AccessibilityCategory.seatingAvailability: 4.0,
    AccessibilityCategory.signageAndWayfinding: 4.0,
  };

  bool _isSubmitting = false;

  final List<String> _reviewerTags = [
    'Wheelchair User',
    'Power Chair User',
    'Senior / Mobility Aid',
    'Blind / Low Vision',
    'Caregiver / Parent',
    'Community Scout',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlaceId = widget.initialPlaceId;
    if (_selectedPlaceId == null && widget.repository.places.isNotEmpty) {
      _selectedPlaceId = widget.repository.places.first.id;
    }
    _visitDate = DateTime.now();
    _commentController = TextEditingController();
    _reviewerNameController = TextEditingController(
      text: widget.repository.userProfile.name,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _reviewerNameController.dispose();
    super.dispose();
  }

  String _getRatingLabel(double? rating) {
    if (rating == null) return 'Unknown / Not Rated';
    final rounded = rating.round();
    switch (rounded) {
      case 1:
        return '1 — Very Poor';
      case 2:
        return '2 — Poor';
      case 3:
        return '3 — Fair';
      case 4:
        return '4 — Good';
      case 5:
        return '5 — Excellent';
      default:
        return '$rating / 5';
    }
  }

  Color _getRatingColor(double? rating) {
    if (rating == null) return AppTheme.statusSlate;
    if (rating >= 4.0) return AppTheme.statusGreen;
    if (rating >= 3.0) return AppTheme.statusAmber;
    return AppTheme.statusRed;
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDarkNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a public place to review.')),
      );
      return;
    }

    // Check if at least one category was rated or comment provided
    final ratedCount = _categoryRatings.values.where((r) => r != null).length;
    if (ratedCount == 0 && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least one category rating or comment.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      FacilityStatus statusFromRating(double? val) {
        if (val == null) return FacilityStatus.unknown;
        if (val >= 3.0) return FacilityStatus.available;
        return FacilityStatus.unavailable;
      }

      final review = Review(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
        placeId: _selectedPlaceId!,
        reviewerName: _reviewerNameController.text.trim().isEmpty
            ? 'Community Member'
            : _reviewerNameController.text.trim(),
        reviewerTag: _selectedReviewerTag,
        ratings: Map.from(_categoryRatings),
        facilityObservations: {
          'stepFreeEntry': statusFromRating(_categoryRatings[AccessibilityCategory.stepFreeAccess]),
          'workingLift': statusFromRating(_categoryRatings[AccessibilityCategory.liftsAndRamps]),
          'accessibleWashroom': statusFromRating(_categoryRatings[AccessibilityCategory.accessibleWashrooms]),
          'seatingAvailable': statusFromRating(_categoryRatings[AccessibilityCategory.seatingAvailability]),
          'clearSignage': statusFromRating(_categoryRatings[AccessibilityCategory.signageAndWayfinding]),
        },
        comment: _commentController.text.trim(),
        visitDate: _visitDate,
        createdAt: DateTime.now(),
        isVerifiedVolunteer: true,
      );

      final updatedPlace = await widget.repository.submitReview(review);

      if (!mounted) return;

      // Show Success Dialog with updated score
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final score = updatedPlace.overallScore?.round();
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: AppTheme.statusGreen, size: 28),
                SizedBox(width: 10),
                Text('Review Submitted!', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thank you for reporting accessibility at ${updatedPlace.name}.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTealLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: AppTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'New Score: ${score != null ? "$score/100" : "Updated"} (${updatedPlace.shortStatus})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryTealDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The AI accessibility summary has been dynamically updated with your observations.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate to place report
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailsScreen(
                        placeId: updatedPlace.id,
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
                child: const Text('View Updated Report'),
              ),
            ],
          );
        },
      );

      // Reset form
      _commentController.clear();
      setState(() {
        _isSubmitting = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = widget.repository.places;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Feedback'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // Guidance Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.volunteer_activism_rounded, color: AppTheme.primaryTeal, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your first-hand experience helps wheelchair users, elderly people, and caregivers travel safely. "Unknown" indicates lack of information, not an obstacle.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryTealDark,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Place Selector
            const Text(
              'Select Public Place',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDarkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPlaceId,
                  isExpanded: true,
                  hint: const Text('Choose a location to review'),
                  items: places.map((place) {
                    return DropdownMenuItem<String>(
                      value: place.id,
                      child: Text(
                        '${place.name} (${place.category})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPlaceId = val;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Reviewer Persona & Date Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Perspective',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDarkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedReviewerTag,
                            isExpanded: true,
                            items: _reviewerTags.map((tag) {
                              return DropdownMenuItem<String>(
                                value: tag,
                                child: Text(tag, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedReviewerTag = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date of Visit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDarkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickVisitDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primaryTeal),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d, yyyy').format(_visitDate),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Five Category Rating Sections
            const Text(
              'Rate Accessibility Categories (1 to 5)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDarkNavy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '1 = Very Poor, 2 = Poor, 3 = Fair, 4 = Good, 5 = Excellent',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),

            ...AccessibilityCategory.values.map((cat) => _buildCategoryRatingCard(cat)),

            const SizedBox(height: 20),

            // Written Comment Field
            const Text(
              'Written Observations (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDarkNavy,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe details like ramp slope, lift size, door width, staff helpfulness, or specific barriers encountered...',
                hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Recalculating Accessibility...' : 'Submit Accessibility Report',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRatingCard(AccessibilityCategory category) {
    final currentRating = _categoryRatings[category];
    final isUnknown = currentRating == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnknown ? AppTheme.borderLight : AppTheme.primaryTeal.withOpacity(0.5),
          width: isUnknown ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 20, color: AppTheme.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${category.title} (${category.weightPercentage}% weight)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                  ),
                ),
              ),
              // Rating status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getRatingColor(currentRating).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getRatingLabel(currentRating),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getRatingColor(currentRating),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            category.description,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
          ),
          const SizedBox(height: 12),

          // Rating 1-5 selection buttons
          Row(
            children: [
              ...List.generate(5, (index) {
                final starValue = (index + 1).toDouble();
                final isSelected = currentRating != null && currentRating >= starValue;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _categoryRatings[category] = starValue;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getRatingColor(starValue)
                              : AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppTheme.textDarkNavy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 8),

          // Mark as Unknown Toggle
          Row(
            children: [
              Checkbox(
                value: isUnknown,
                activeColor: AppTheme.statusSlate,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _categoryRatings[category] = null;
                    } else {
                      _categoryRatings[category] = 3.0; // default fair if unchecking
                    }
                  });
                },
              ),
              const Text(
                'Mark as Unknown / Not Observed on this visit',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
