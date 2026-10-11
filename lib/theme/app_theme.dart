import 'package:flutter/material.dart';

class AppTheme {
  // Brand color palette — Yellow and Gold
  static const Color primaryTeal = Color(0xFFF5B800);
  static const Color primaryTealLight = Color(0xFFFFF4CC);
  static const Color primaryTealDark = Color(0xFF8A6500);

  static const Color secondaryBlue = Color(0xFF2563EB);
  static const Color secondaryBlueLight = Color(0xFFDBEAFE);

  static const Color backgroundWarm = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  static const Color textDarkNavy = Color(0xFF172033);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Accessibility status colors
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusGreenLight = Color(0xFFDCFCE7);
  static const Color statusGreenBorder = Color(0xFF86EFAC);

  static const Color statusAmber = Color(0xFF8A6500);
  static const Color statusAmberLight = Color(0xFFFFF4CC);
  static const Color statusAmberBorder = Color(0xFFF5B800);

  static const Color statusRed = Color(0xFFDC2626);
  static const Color statusRedLight = Color(0xFFFEE2E2);
  static const Color statusRedBorder = Color(0xFFFCA5A5);

  static const Color statusSlate = Color(0xFF64748B);
  static const Color statusSlateLight = Color(0xFFF1F5F9);
  static const Color statusSlateBorder = Color(0xFFCBD5E1);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        onPrimary: const Color(0xFF202020),
        secondary: secondaryBlue,
        surface: surfaceWhite,
        error: statusRed,
      ),
      scaffoldBackgroundColor: backgroundWarm,
      fontFamily: 'Inter',

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineMedium: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        headlineSmall: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleLarge: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: textDarkNavy,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(color: textDarkNavy, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(color: textDarkNavy, fontSize: 14, height: 1.4),
        bodySmall: TextStyle(color: textMuted, fontSize: 12, height: 1.35),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textDarkNavy,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDarkNavy,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTealDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: const Color(0xFF202020),
          minimumSize: const Size(48, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTealDark,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: primaryTeal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: borderLight),
        selectedColor: primaryTealLight,
        backgroundColor: surfaceWhite,
        labelStyle: const TextStyle(
          color: textDarkNavy,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryTealDark,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
