import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ai_summary.dart';
import '../theme/app_theme.dart';

class AiSummaryCard extends StatelessWidget {
  final AiSummary? aiSummary;
  final VoidCallback? onRegenerate;
  final bool isRegenerating;

  const AiSummaryCard({
    super.key,
    required this.aiSummary,
    this.onRegenerate,
    this.isRegenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    if (aiSummary == null) {
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
              _buildHeader(),
              const SizedBox(height: 12),
              const Text(
                'No community summary generated yet. Add your feedback below to generate the first accessibility summary.',
                style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 249, 255, 186)),
              ),
            ],
          ),
        ),
      );
    }

    final summary = aiSummary!;
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(summary.generatedAt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF99F6E4), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDFA), // Very light teal
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),

            // Section 1: Overall community experience
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryTeal),
                      SizedBox(width: 6),
                      Text(
                        'Overall Community Experience',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTealDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary.overallExperience,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textDarkNavy,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Positive Accessibility Features
            if (summary.positiveFeatures.isNotEmpty) ...[
              _buildSectionHeader(
                'Positive Accessibility Features',
                Icons.check_circle_rounded,
                AppTheme.statusGreen,
              ),
              const SizedBox(height: 8),
              ...summary.positiveFeatures.map(
                (item) => _buildBulletItem(
                  item,
                  Icons.check_rounded,
                  AppTheme.statusGreen,
                  AppTheme.statusGreenLight,
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Section 3: Commonly Reported Barriers
            if (summary.reportedBarriers.isNotEmpty) ...[
              _buildSectionHeader(
                'Commonly Reported Barriers',
                Icons.warning_amber_rounded,
                AppTheme.statusRed,
              ),
              const SizedBox(height: 8),
              ...summary.reportedBarriers.map(
                (item) => _buildBulletItem(
                  item,
                  Icons.close_rounded,
                  AppTheme.statusRed,
                  AppTheme.statusRedLight,
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Section 4: Conflicting Reports
            if (summary.conflictingReports.isNotEmpty) ...[
              _buildSectionHeader(
                'Conflicting Visitor Reports',
                Icons.swap_horiz_rounded,
                AppTheme.statusAmber,
              ),
              const SizedBox(height: 8),
              ...summary.conflictingReports.map(
                (item) => _buildBulletItem(
                  item,
                  Icons.priority_high_rounded,
                  AppTheme.statusAmber,
                  AppTheme.statusAmberLight,
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Section 5: Information That Still Needs Verification
            if (summary.needsVerification.isNotEmpty) ...[
              _buildSectionHeader(
                'Needs On-Site Verification',
                Icons.help_outline_rounded,
                AppTheme.statusSlate,
              ),
              const SizedBox(height: 8),
              ...summary.needsVerification.map(
                (item) => _buildBulletItem(
                  item,
                  Icons.question_mark_rounded,
                  AppTheme.statusSlate,
                  AppTheme.statusSlateLight,
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1, color: AppTheme.borderLight),
            const SizedBox(height: 12),

            // Footer metadata
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Synthesized from ${summary.reviewsAnalyzedCount} community reviews',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDarkNavy,
                        ),
                      ),
                      Text(
                        'Last updated $dateStr',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRegenerate != null)
                  TextButton.icon(
                    onPressed: isRegenerating ? null : onRegenerate,
                    icon: isRegenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(
                      isRegenerating ? 'Analyzing...' : 'Refresh AI',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.psychology_alt_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Accessibility Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDarkNavy,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    aiSummary?.isLiveAi == true ? 'Live LLM Engine' : 'Structured Community Synthesis',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTealDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String text, IconData icon, Color color, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textDarkNavy,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
