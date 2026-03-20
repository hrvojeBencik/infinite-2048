import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/progression/domain/entities/tile_theme.dart'
    as theme_model;
import 'app_colors.dart';

class TileThemes {
  TileThemes._();

  static theme_model.TileTheme _activeTheme() {
    try {
      final box = Hive.box(AppConstants.hiveSettingsBox);
      final data = box.get('player_profile');
      if (data != null) {
        final decoded = _extractThemeId(data as String);
        if (decoded != null) {
          return theme_model.TileThemes.getById(decoded);
        }
      }
    } catch (e) {
      debugPrint('Failed to load active tile theme: $e');
    }
    return theme_model.TileThemes.classic;
  }

  static String? _extractThemeId(String json) {
    final match = RegExp(r'"activeTileThemeId"\s*:\s*"([^"]+)"').firstMatch(json);
    return match?.group(1);
  }

  static Color tileColor(int value) {
    return _activeTheme().colorForValue(value);
  }

  static Color tileTextColor(int value) {
    return _activeTheme().textColorForValue(value);
  }

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
