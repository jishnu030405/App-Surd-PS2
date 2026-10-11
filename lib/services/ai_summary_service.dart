import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../models/accessibility_category.dart';
import '../models/facility_status.dart';
import '../models/ai_summary.dart';

class AiSummaryService {
  // Optional URL for your own backend. Keep LLM provider API keys on that server;
  // never embed provider secrets in a Flutter app distributed to users.
  final String? backendUrl;

  AiSummaryService({this.backendUrl});

  /// Generates a structured AI summary for a place based on its actual reviews and structured data.
  /// Falls back smoothly to the deterministic rule-based synthesis engine if no backend is configured or network is unreachable.
  Future<AiSummary> generateSummary(Place place, {bool forceRuleBased = false}) async {
    // Only call a configured backend. Never call a provider API directly from the app.
    if (!forceRuleBased && backendUrl != null && backendUrl!.trim().isNotEmpty) {
      try {
        final remoteSummary = await _callRemoteLlm(place);
        if (remoteSummary != null) return remoteSummary;
      } catch (e) {
        // Fall back gracefully to rule-based engine on any error
      }
    }

    // High quality deterministic rule-based synthesis engine
    return _generateDeterministicSummary(place);
  }

  /// Rule-based synthesis engine that rigorously evaluates the actual reviews and ratings
  AiSummary _generateDeterministicSummary(Place place) {
    final reviews = place.reviews;
    final reviewCount = reviews.length;

    // 1. Positive features analysis
    final positiveFeatures = <String>[];
    // 2. Reported barriers
    final reportedBarriers = <String>[];
    // 3. Conflicting reports
    final conflictingReports = <String>[];
    // 4. Information needing verification
    final needsVerification = <String>[];

    // Inspect structured facility statuses
    if (place.stepFreeEntry == FacilityStatus.available) {
      positiveFeatures.add('Step-free entrance is reported as available in the current data');
    } else if (place.stepFreeEntry == FacilityStatus.unavailable) {
      reportedBarriers.add('Stairs or physical thresholds present at main entrance without level ramp');
    } else {
      needsVerification.add('Main entrance step-free accessibility has not been independently verified');
    }

    if (place.workingLift == FacilityStatus.available) {
      positiveFeatures.add('Lift availability is reported in the current data; functionality should be checked before visiting');
    } else if (place.workingLift == FacilityStatus.unavailable) {
      reportedBarriers.add('Elevator unavailable, out of service, or absent for upper levels');
    } else {
      needsVerification.add('Elevator functionality and cabin dimensions need community confirmation');
    }

    if (place.accessibleWashroom == FacilityStatus.available) {
      positiveFeatures.add('An accessible washroom is reported as available; specific fixtures have not necessarily been audited');
    } else if (place.accessibleWashroom == FacilityStatus.unavailable) {
      reportedBarriers.add('Restrooms lack wheelchair clearance, grab bars, or are currently locked');
    } else {
      needsVerification.add('Washroom door width and accessibility fixtures require on-site verification');
    }

    if (place.seatingAvailable == FacilityStatus.available) {
      positiveFeatures.add('Resting seating available at reasonable intervals');
    } else if (place.seatingAvailable == FacilityStatus.unavailable) {
      reportedBarriers.add('Lack of seating along extended walking paths or waiting halls');
    }

    if (place.clearSignage == FacilityStatus.available) {
      positiveFeatures.add('High-contrast directional signage and clear visual markers');
    } else if (place.clearSignage == FacilityStatus.unavailable) {
      reportedBarriers.add('Signage lacks high contrast, braille, or clear accessibility wayfinding');
    } else {
      needsVerification.add('Braille/tactile signage status remains unconfirmed');
    }

    // Check for conflicting reports across reviews
    for (final cat in AccessibilityCategory.values) {
      final ratingsForCat = reviews
          .map((r) => r.ratings[cat])
          .where((r) => r != null)
          .map((r) => r!)
          .toList();

      if (ratingsForCat.length >= 2) {
        final hasLow = ratingsForCat.any((r) => r <= 2.5);
        final hasHigh = ratingsForCat.any((r) => r >= 4.0);
        if (hasLow && hasHigh) {
          conflictingReports.add(
            'Community ratings for ${cat.title} differ between visitors (some rated high while others reported difficulties).',
          );
        }
      }
    }

    // Extract excerpts and themes from review comments
    for (final r in reviews) {
      final comment = r.comment.trim();
      if (comment.isEmpty) continue;
      
      // Look for specific positive/barrier mentions
      final lower = comment.toLowerCase();
      if ((lower.contains('smooth') || lower.contains('excellent') || lower.contains('spacious') || lower.contains('helpful')) &&
          positiveFeatures.length < 5) {
        positiveFeatures.add('Visitor observation: "${_truncateText(comment, 90)}"');
      }
      if ((lower.contains('barrier') || lower.contains('broken') || lower.contains('stairs') || lower.contains('crowded') || lower.contains('unsafe') || lower.contains('frustrat')) &&
          reportedBarriers.length < 5) {
        reportedBarriers.add('Visitor report: "${_truncateText(comment, 90)}"');
      }
    }

    // Formulate Overall Experience synthesis
    String overall;
    final score = place.overallScore;
    if (reviewCount == 0) {
      overall = 'No community reviews have been recorded yet for ${place.name}. Accessibility details are based on initial facility registration.';
    } else if (score != null && score >= 80) {
      overall = 'The weighted score is high based on the categories currently rated across $reviewCount community reviews. Check each facility status and the data coverage before deciding whether this place meets your needs.';
    } else if (score != null && score >= 55) {
      overall = 'The available ratings suggest partial accessibility across the categories reported in $reviewCount community reviews. Review individual facility statuses and recent comments for specific barriers.';
    } else if (score != null) {
      overall = 'The current accessibility score is low based on the available ratings. Review individual facility statuses and recent comments to identify reported barriers before visiting.';
    } else {
      overall = 'Collected feedback is currently partial (coverage: ${place.coveragePercentage.round()}%). More community submissions are needed for a comprehensive score.';
    }

    // Build unified summary text
    final summaryBuffer = StringBuffer(overall);
    if (positiveFeatures.isNotEmpty) {
      summaryBuffer.write(' Positives include: ${positiveFeatures.first}.');
    }
    if (reportedBarriers.isNotEmpty) {
      summaryBuffer.write(' Reported caution: ${reportedBarriers.first}.');
    }
    if (needsVerification.isNotEmpty) {
      summaryBuffer.write(' Note: ${needsVerification.first}.');
    }

    return AiSummary(
      overallExperience: overall,
      positiveFeatures: positiveFeatures.isEmpty ? ['No major positive highlights logged yet'] : positiveFeatures,
      reportedBarriers: reportedBarriers.isEmpty ? ['No active barriers reported in recent reviews'] : reportedBarriers,
      conflictingReports: conflictingReports,
      needsVerification: needsVerification.isEmpty ? ['No unknown facility statuses were flagged in the current data; this does not represent an independent accessibility audit'] : needsVerification,
      summaryText: summaryBuffer.toString(),
      reviewsAnalyzedCount: reviewCount,
      generatedAt: DateTime.now(),
      isLiveAi: false,
    );
  }

  Future<AiSummary?> _callRemoteLlm(Place place) async {
    final endpoint = backendUrl!.trim();
    final payload = {
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content': 'You are an objective accessibility analysis engine. Summarize the accessibility experience based strictly on provided reviews. Do not invent facts.',
        },
        {
          'role': 'user',
          'content': jsonEncode({
            'placeName': place.name,
            'category': place.category,
            'reviews': place.reviews.map((r) => {'rating': r.ratings.toString(), 'comment': r.comment}).toList(),
            'facilityStatuses': place.facilityStatuses.map((k, v) => MapEntry(k, v.name)),
          }),
        }
      ],
      'response_format': {'type': 'json_object'},
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      if (content != null) {
        final parsed = jsonDecode(content);
        return AiSummary(
          overallExperience: parsed['overallExperience'] ?? '',
          positiveFeatures: List<String>.from(parsed['positiveFeatures'] ?? []),
          reportedBarriers: List<String>.from(parsed['reportedBarriers'] ?? []),
          conflictingReports: List<String>.from(parsed['conflictingReports'] ?? []),
          needsVerification: List<String>.from(parsed['needsVerification'] ?? []),
          summaryText: parsed['summaryText'] ?? '',
          reviewsAnalyzedCount: place.reviews.length,
          generatedAt: DateTime.now(),
          isLiveAi: true,
        );
      }
    }
    return null;
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
