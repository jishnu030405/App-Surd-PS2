import 'package:flutter/material.dart';
import '../models/facility_status.dart';

class FacilityIndicatorChip extends StatelessWidget {
  final String label;
  final FacilityStatus status;
  final IconData facilityIcon;
  final bool compact;

  const FacilityIndicatorChip({
    super.key,
    required this.label,
    required this.status,
    required this.facilityIcon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status.color;
    final bgColor = status.backgroundColor;
    final borderColor = status.borderColor;
    final statusText = status.displayName;

    final semanticText = '$label: $statusText';

    if (compact) {
      return Semantics(
        label: semanticText,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(facilityIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 3),
              Icon(status.icon, size: 12, color: statusColor),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: semanticText,
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
            Icon(facilityIcon, size: 16, color: statusColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, size: 12, color: statusColor),
                  const SizedBox(width: 3),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
