import 'package:flutter/material.dart';
import '../models/place.dart';
import '../models/accessibility_category.dart';
import '../theme/app_theme.dart';

class ScoreBreakdownCard extends StatelessWidget {
  final Place place;

  const ScoreBreakdownCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final scoreResult = place.scoreResult;
    final hasScore = scoreResult.hasSufficientData;
    final score = scoreResult.roundedScore;
    final statusColor = scoreResult.statusColor;
    final statusBgColor = scoreResult.statusBackgroundColor;
    final statusBorderColor = scoreResult.statusBorderColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Big Score Gauge & Interpretation
            Row(
              children: [
                // Score Circle Display
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: statusBorderColor, width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hasScore ? '$score' : '--',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          hasScore ? 'OUT OF 100' : 'UNKNOWN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: statusColor.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Interpretation & Coverage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scoreResult.interpretationLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scoreResult.detailedDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Data Coverage Progress Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data Coverage: ${scoreResult.coveragePercentage.round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDarkNavy,
                        ),
                      ),
                      Text(
                        '${scoreResult.ratedCategoriesCount} of ${scoreResult.totalCategoriesCount} categories rated',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: scoreResult.coveragePercentage / 100,
                      backgroundColor: AppTheme.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scoreResult.coveragePercentage >= 80
                            ? AppTheme.statusGreen
                            : (scoreResult.coveragePercentage >= 50
                                ? AppTheme.statusAmber
                                : AppTheme.statusRed),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Regulatory Disclaimer Alert
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppTheme.primaryTeal,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AccessPath provides community-reported insights. Scores reflect visitor submissions and do not constitute legal proof of regulatory accessibility compliance.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryTealDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Five Category Detailed Breakdown
            const Text(
              'Accessibility Category Ratings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDarkNavy,
              ),
            ),
            const SizedBox(height: 12),

            ...AccessibilityCategory.values.map((category) {
              final rating = place.categoryRatings[category];
              final note = place.categoryNotes[category];
              return _buildCategoryItem(category, rating, note);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    AccessibilityCategory category,
    double? rating,
    String? note,
  ) {
    final isRated = rating != null && rating > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWarm,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Icon(category.icon, size: 18, color: AppTheme.primaryTeal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDarkNavy,
                      ),
                    ),
                    Text(
                      'Score Weight: ${category.weightPercentage}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating Badge
              if (isRated) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRatingColor(rating).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getRatingColor(rating).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        '${rating.toStringAsFixed(1)} / 5',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _getRatingColor(rating),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.statusSlateLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.statusSlateBorder),
                  ),
                  child: const Text(
                    'Unknown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.statusSlate,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (isRated) ...[
            const SizedBox(height: 8),
            // Progress rating bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: rating / 5.0,
                backgroundColor: AppTheme.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(_getRatingColor(rating)),
                minHeight: 5,
              ),
            ),
          ],

          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textDarkNavy,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return AppTheme.statusGreen;
    if (rating >= 3.0) return AppTheme.statusAmber;
    return AppTheme.statusRed;
  }
}
