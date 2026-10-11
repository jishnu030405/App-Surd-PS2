import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum FacilityStatus {
  available,
  unavailable,
  unknown;

  String get displayName {
    switch (this) {
      case FacilityStatus.available:
        return 'Available';
      case FacilityStatus.unavailable:
        return 'Unavailable';
      case FacilityStatus.unknown:
        return 'Unconfirmed';
    }
  }

  IconData get icon {
    switch (this) {
      case FacilityStatus.available:
        return Icons.check_circle_rounded;
      case FacilityStatus.unavailable:
        return Icons.cancel_rounded;
      case FacilityStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FacilityStatus.available:
        return AppTheme.statusGreen;
      case FacilityStatus.unavailable:
        return AppTheme.statusRed;
      case FacilityStatus.unknown:
        return AppTheme.statusSlate;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case FacilityStatus.available:
        return AppTheme.statusGreenLight;
      case FacilityStatus.unavailable:
        return AppTheme.statusRedLight;
      case FacilityStatus.unknown:
        return AppTheme.statusSlateLight;
    }
  }

  Color get borderColor {
    switch (this) {
      case FacilityStatus.available:
        return AppTheme.statusGreenBorder;
      case FacilityStatus.unavailable:
        return AppTheme.statusRedBorder;
      case FacilityStatus.unknown:
        return AppTheme.statusSlateBorder;
    }
  }

  static FacilityStatus fromString(String? value) {
    if (value == null) return FacilityStatus.unknown;
    switch (value.toLowerCase()) {
      case 'available':
        return FacilityStatus.available;
      case 'unavailable':
        return FacilityStatus.unavailable;
      default:
        return FacilityStatus.unknown;
    }
  }
}
