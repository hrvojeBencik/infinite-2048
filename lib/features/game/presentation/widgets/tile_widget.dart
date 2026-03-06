import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tile_themes.dart';
import '../../domain/entities/tile.dart';
import '../../domain/entities/special_tile_type.dart';
import 'package:google_fonts/google_fonts.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double cellSize;
  final double spacing;
  final bool isHammerMode;
  final VoidCallback? onTap;

  const TileWidget({
    super.key,
    required this.tile,
    required this.cellSize,
    this.spacing = 4,
    this.isHammerMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = cellSize - spacing;

    Widget tileContent = Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(tileSize * 0.12),
        border: _borderForSpecialType,
        boxShadow: [
          BoxShadow(
            color: _backgroundColor.withAlpha(80),
            blurRadius: tile.wasMerged ? 12 : 4,
            spreadRadius: tile.wasMerged ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (tile.specialType != SpecialTileType.blocker)
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(tileSize * 0.08),
                  child: Text(
                    tile.value.toString(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: TileThemes.tileFontSize(tile.value, tileSize),
                      fontWeight: FontWeight.w800,
                      color: TileThemes.tileTextColor(tile.value),
                    ),
                  ),
                ),
              ),
            ),
          if (tile.specialType == SpecialTileType.blocker)
            Center(
              child: Icon(
                Icons.block,
                size: tileSize * 0.4,
                color: Colors.grey.shade600,
              ),
            ),
          if (tile.specialType != SpecialTileType.none &&
              tile.specialType != SpecialTileType.blocker)
            Positioned(
              top: 2,
              right: 2,
              child: _specialTypeIndicator(tileSize),
            ),
          if (tile.isFrozen) _frozenOverlay(tileSize),
          if (isHammerMode)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(40),
                  borderRadius: BorderRadius.circular(tileSize * 0.12),
                  border: Border.all(color: AppColors.error, width: 2),
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: tileSize * 0.3,
                ),
              ),
            ),
        ],
      ),
    );

    if (tile.wasMerged) {
      tileContent = tileContent
          .animate()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1.0, 1.0),
            duration: 200.ms,
            curve: Curves.easeOut,
          );
    } else if (tile.wasSpawned) {
      tileContent = tileContent
          .animate()
          .scale(
            begin: const Offset(0.0, 0.0),
            end: const Offset(1.0, 1.0),
            duration: 150.ms,
            curve: Curves.easeOut,
          );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: tileContent);
    }

    return tileContent;
  }

  Color get _backgroundColor {
    if (tile.specialType == SpecialTileType.blocker) {
      return const Color(0xFF2A2A2A);
    }
    return TileThemes.tileColor(tile.value);
  }

  Border? get _borderForSpecialType {
    switch (tile.specialType) {
      case SpecialTileType.bomb:
        return Border.all(color: Colors.red.shade400, width: 2);
      case SpecialTileType.multiplier:
        return Border.all(color: AppColors.secondary, width: 2);
      case SpecialTileType.wildcard:
        return Border.all(color: AppColors.primary, width: 2);
      default:
        return null;
    }
  }

  Widget _specialTypeIndicator(double size) {
    IconData icon;
    Color color;
    switch (tile.specialType) {
      case SpecialTileType.bomb:
        icon = Icons.local_fire_department;
        color = Colors.red;
      case SpecialTileType.ice:
        icon = Icons.ac_unit;
        color = Colors.cyan;
      case SpecialTileType.multiplier:
        icon = Icons.close;
        color = AppColors.secondary;
      case SpecialTileType.wildcard:
        icon = Icons.star;
        color = AppColors.primary;
      default:
        return const SizedBox.shrink();
    }
    return Icon(icon, size: size * 0.15, color: color);
  }

  Widget _frozenOverlay(double size) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.cyan.withAlpha(50),
          borderRadius: BorderRadius.circular(size * 0.12),
          border: Border.all(color: Colors.cyan.withAlpha(120), width: 1.5),
        ),
        child: Center(
          child: Icon(
            Icons.ac_unit,
            size: size * 0.25,
            color: Colors.cyan.withAlpha(180),
          ),
        ),
      ),
    );
  }
}
