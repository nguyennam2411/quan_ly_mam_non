import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    ),
    scaffoldBackgroundColor: AppColors.background,
    
    // Typography: Plus Jakarta Sans (Headings) & Be Vietnam Pro (Body)
    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(color: AppColors.onBackground, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.plusJakartaSans(color: AppColors.onBackground, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.plusJakartaSans(color: AppColors.onBackground, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.plusJakartaSans(color: AppColors.onBackground, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.plusJakartaSans(color: AppColors.onBackground, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.plusJakartaSans(color: AppColors.onBackground, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.beVietnamPro(color: AppColors.onBackground, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.beVietnamPro(color: AppColors.onBackground, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.beVietnamPro(color: AppColors.onBackground, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.beVietnamPro(color: AppColors.onSurface, fontSize: 16),
      bodyMedium: GoogleFonts.beVietnamPro(color: AppColors.onSurface, fontSize: 14),
      bodySmall: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant, fontSize: 12),
      labelLarge: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
    ),

    // Button Theme: "High-rounded (full)" cho primary button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), 
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Focus & Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary.withOpacity(0.20),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
    ),
  );
}
