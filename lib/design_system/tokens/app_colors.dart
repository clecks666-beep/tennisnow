import 'package:flutter/material.dart';

/// Color tokens — the ONLY place colors are defined (CLAUDE.md §5).
/// Screens compose these; they never declare their own colors.
class AppColors {
  AppColors._();

  // Brand: tennis-court green with an energetic accent.
  static const Color primary = Color(0xFF2E7D32); // court green
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFC6FF00); // optic-yellow ball

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF6F7F4);
  static const Color outline = Color(0xFFE2E5DE);

  static const Color textPrimary = Color(0xFF1A1C19);
  static const Color textSecondary = Color(0xFF5B5F58);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB3261E);

  // Semantic colors for match results.
  static const Color win = Color(0xFF2E7D32);
  static const Color loss = Color(0xFFB3261E);
  static const Color draw = Color(0xFF8A6D00);
}
