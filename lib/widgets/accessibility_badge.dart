import 'package:flutter/material.dart';
import '../utils/accessibility_score.dart';

class AccessibilityBadge extends StatelessWidget {
  final ScoreCalculationResult scoreResult;
  final bool compact;
  final bool showCoverage;

  const AccessibilityBadge({
    super.key,
    required this.scoreResult,
    this.compact = false,
    this.showCoverage = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = scoreResult.hasSufficientData;
    final score = scoreResult.roundedScore;
    final label = scoreResult.interpretationLabel;
    final color = scoreResult.statusColor;
    final bgColor = scoreResult.statusBackgroundColor;
    final borderColor = scoreResult.statusBorderColor;

    if (compact) {
      return Semantics(
        label: hasScore
            ? 'Accessibility score: $score out of 100, $label'
            : 'Accessibility score: Not enough information',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasScore ? Icons.verified_user_rounded : Icons.help_outline_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                hasScore ? '$score' : 'N/A',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (hasScore)
                Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: hasScore
          ? 'Accessibility score: $score out of 100, $label, data coverage ${scoreResult.coveragePercentage.round()} percent'
          : 'Accessibility score: Not enough information to calculate score',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasScore ? '$score / 100' : 'Score Pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (showCoverage && hasScore) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: scoreResult.coveragePercentage / 100,
                        backgroundColor: borderColor.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${scoreResult.coveragePercentage.round()}% data coverage',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
