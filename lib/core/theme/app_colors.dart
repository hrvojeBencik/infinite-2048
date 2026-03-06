import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0E21);
  static const Color backgroundLight = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFF1F2F50);

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  static const Color secondary = Color(0xFFFFD700);
  static const Color secondaryLight = Color(0xFFFFE44D);

  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB40);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8D8D8D);
  static const Color textTertiary = Color(0xFF5A5A6A);

  static const Color cardBorder = Color(0xFF2A2A4A);
  static const Color divider = Color(0xFF2A2A4A);

  static const Color gridBackground = Color(0xFF0D1128);
  static const Color cellEmpty = Color(0xFF1A1F3A);

  // Zone accent colors
  static const Color zoneGenesis = Color(0xFF6C63FF);
  static const Color zoneInferno = Color(0xFFFF4444);
  static const Color zoneGlacier = Color(0xFF40C4FF);
  static const Color zoneNexus = Color(0xFFFFD700);
  static const Color zoneVoid = Color(0xFF9C27B0);
  static const Color zoneEndless = Color(0xFF00E676);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, backgroundLight],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFFFFA000)],
  );
}
