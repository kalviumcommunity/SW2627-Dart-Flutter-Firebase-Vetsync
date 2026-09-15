import 'package:flutter/material.dart';

/// Centralized color palette for VetSync's modern veterinary healthcare identity.
class AppColors {
  AppColors._();

  // Primary Healthcare Brand - Deep Emerald / Teal
  static const Color primary = Color(0xFF0F766E); // Teal 700
  static const Color primaryDark = Color(0xFF0D5C52); // Teal 900
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primarySoft = Color(0xFFCCFBF1); // Teal 100
  static const Color primaryUltraSoft = Color(0xFFF0FDFA); // Teal 50

  // Secondary Accent - Mint & Eucalyptus
  static const Color secondary = Color(0xFF10B981); // Emerald 500
  static const Color secondaryLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color accent = Color(0xFF06B6D4); // Cyan 500
  static const Color accentSoft = Color(0xFFE0F2FE); // Cyan 50

  // Canvas & Backgrounds - Medical Off-Whites
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceSubtle = Color(0xFFF8FAFC);

  // Typography - Slate / Charcoal
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFF94A3B8); // Slate 400

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderFocused = Color(0xFF0F766E);

  // Status & Clinical Flags
  // Warning / Overdue Follow-ups (Warm Amber)
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningSurface = Color(0xFFFFFBEB); // Amber 50
  static const Color warningBorder = Color(0xFFFDE68A); // Amber 200

  // Critical / High Alert (Soft Crimson / Rose)
  static const Color error = Color(0xFFE11D48); // Rose 600
  static const Color errorSurface = Color(0xFFFFF1F2); // Rose 50
  static const Color errorBorder = Color(0xFFFECDD3); // Rose 200

  // Success / Up to Date (Emerald Green)
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successSurface = Color(0xFFECFDF5); // Emerald 50
  static const Color successBorder = Color(0xFFA7F3D0); // Emerald 200

  // Clinical Tag Colors (Medications, Vaccines, Specialty)
  static const Color medication = Color(0xFF7C3AED); // Violet 600
  static const Color medicationSurface = Color(0xFFF5F3FF); // Violet 50
  static const Color medicationBorder = Color(0xFFDDD6FE); // Violet 200

  static const Color vaccine = Color(0xFF0284C7); // Sky 600
  static const Color vaccineSurface = Color(0xFFF0F9FF); // Sky 50
  static const Color vaccineBorder = Color(0xFFBAE6FD); // Sky 200

  // Shadow Colors
  static Color shadowSubtle = const Color(0xFF0F172A).withAlpha(10);
  static Color shadowMedium = const Color(0xFF0F172A).withAlpha(20);
}
