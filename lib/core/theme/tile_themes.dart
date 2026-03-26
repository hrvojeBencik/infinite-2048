import 'package:flutter/material.dart';
import 'app_colors.dart';

class TileThemes {
  TileThemes._();

  static double tileFontSize(int value, double cellSize) {
    final digits = value.toString().length;
    if (digits <= 2) return cellSize * 0.38;
    if (digits == 3) return cellSize * 0.32;
    if (digits == 4) return cellSize * 0.26;
    if (digits == 5) return cellSize * 0.22;
    return cellSize * 0.18;
  }

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
