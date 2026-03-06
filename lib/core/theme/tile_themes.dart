import 'package:flutter/material.dart';
import 'app_colors.dart';

class TileThemes {
  TileThemes._();

  static Color tileColor(int value) {
    return _defaultTileColors[value] ?? AppColors.primary;
  }

  static Color tileTextColor(int value) {
    if (value <= 4) return const Color(0xFF776E65);
    return Colors.white;
  }

  static double tileFontSize(int value, double cellSize) {
    final digits = value.toString().length;
    if (digits <= 2) return cellSize * 0.38;
    if (digits == 3) return cellSize * 0.32;
    if (digits == 4) return cellSize * 0.26;
    if (digits == 5) return cellSize * 0.22;
    return cellSize * 0.18;
  }

  static final Map<int, Color> _defaultTileColors = {
    2: const Color(0xFFE8E0D6),
    4: const Color(0xFFE8DCC4),
    8: const Color(0xFFF2B179),
    16: const Color(0xFFF59563),
    32: const Color(0xFFF67C5F),
    64: const Color(0xFFF65E3B),
    128: const Color(0xFFEDCF72),
    256: const Color(0xFFEDCC61),
    512: const Color(0xFFEDC850),
    1024: const Color(0xFFEDC53F),
    2048: const Color(0xFFEDC22E),
    4096: const Color(0xFF6C63FF),
    8192: const Color(0xFF5A4FCF),
    16384: const Color(0xFFFF4081),
    32768: const Color(0xFFFF1744),
    65536: const Color(0xFFFFD700),
  };

  static Color specialTileOverlay(String type) {
    switch (type) {
      case 'bomb':
        return Colors.red.withAlpha(80);
      case 'ice':
        return Colors.cyan.withAlpha(80);
      case 'multiplier':
        return AppColors.secondary.withAlpha(80);
      case 'wildcard':
        return AppColors.primary.withAlpha(80);
      case 'blocker':
        return Colors.grey.withAlpha(180);
      default:
        return Colors.transparent;
    }
  }

  static List<Color> zoneGradient(String zoneId) {
    switch (zoneId) {
      case 'genesis':
        return [AppColors.zoneGenesis, AppColors.zoneGenesis.withAlpha(150)];
      case 'inferno':
        return [AppColors.zoneInferno, AppColors.zoneInferno.withAlpha(150)];
      case 'glacier':
        return [AppColors.zoneGlacier, AppColors.zoneGlacier.withAlpha(150)];
      case 'nexus':
        return [AppColors.zoneNexus, AppColors.zoneNexus.withAlpha(150)];
      case 'void':
        return [AppColors.zoneVoid, AppColors.zoneVoid.withAlpha(150)];
      default:
        return [AppColors.zoneEndless, AppColors.zoneEndless.withAlpha(150)];
    }
  }
}
