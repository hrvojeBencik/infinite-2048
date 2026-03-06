import 'dart:math' as math;
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

    Widget tileContent = _buildTile(tileSize);

    if (tile.wasMerged) {
      tileContent = tileContent
          .animate()
          .scale(
            begin: const Offset(1.3, 1.3),
            end: const Offset(1.0, 1.0),
            duration: 350.ms,
            curve: Curves.elasticOut,
          );
    } else if (tile.wasSpawned) {
      tileContent = tileContent
          .animate()
          .scale(
            begin: const Offset(0.0, 0.0),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .fadeIn(duration: 150.ms);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: tileContent);
    }

    return tileContent;
  }

  Widget _buildTile(double tileSize) {
    return Container(
      width: tileSize,
      height: tileSize,
      decoration: _tileDecoration(tileSize),
      child: Stack(
        children: [
          if (tile.specialType == SpecialTileType.bomb)
            _bombBackground(tileSize),
          if (tile.specialType == SpecialTileType.multiplier)
            _multiplierBackground(tileSize),
          if (tile.specialType == SpecialTileType.wildcard)
            _wildcardBackground(tileSize),
          if (tile.specialType == SpecialTileType.blocker)
            _blockerContent(tileSize)
          else
            _valueContent(tileSize),
          if (tile.specialType == SpecialTileType.bomb)
            _bombBadge(tileSize),
          if (tile.specialType == SpecialTileType.multiplier)
            _multiplierBadge(tileSize),
          if (tile.specialType == SpecialTileType.wildcard)
            _wildcardBadge(tileSize),
          if (tile.isFrozen) _frozenOverlay(tileSize),
          if (isHammerMode) _hammerOverlay(tileSize),
        ],
      ),
    );
  }

  BoxDecoration _tileDecoration(double tileSize) {
    final radius = BorderRadius.circular(tileSize * 0.12);

    if (tile.specialType == SpecialTileType.blocker) {
      return BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF333355), width: 2),
      );
    }

    if (tile.specialType == SpecialTileType.bomb) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFFF6666), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      );
    }

    if (tile.specialType == SpecialTileType.multiplier) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFFFE44D), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      );
    }

    if (tile.specialType == SpecialTileType.wildcard) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B83FF), Color(0xFF6C63FF), Color(0xFF4A42DB)],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFADA6FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      );
    }

    return BoxDecoration(
      color: TileThemes.tileColor(tile.value),
      borderRadius: radius,
      boxShadow: [
        BoxShadow(
          color: TileThemes.tileColor(tile.value).withAlpha(80),
          blurRadius: tile.wasMerged ? 12 : 4,
          spreadRadius: tile.wasMerged ? 2 : 0,
        ),
      ],
    );
  }

  Widget _valueContent(double tileSize) {
    Color textColor;
    if (tile.specialType == SpecialTileType.bomb ||
        tile.specialType == SpecialTileType.wildcard) {
      textColor = Colors.white;
    } else if (tile.specialType == SpecialTileType.multiplier) {
      textColor = const Color(0xFF3D2600);
    } else {
      textColor = TileThemes.tileTextColor(tile.value);
    }

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(tileSize * 0.08),
          child: Text(
            tile.value.toString(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: TileThemes.tileFontSize(tile.value, tileSize),
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _blockerContent(double tileSize) {
    return Center(
      child: Icon(
        Icons.block_rounded,
        size: tileSize * 0.45,
        color: const Color(0xFF555577),
      ),
    );
  }

  // --- Bomb visuals ---

  Widget _bombBackground(double tileSize) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tileSize * 0.12),
        child: CustomPaint(
          painter: _RadialPatternPainter(
            color: Colors.orange.withAlpha(50),
          ),
        ),
      ),
    );
  }

  Widget _bombBadge(double tileSize) {
    return Positioned(
      bottom: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.orange.shade800,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.orange.withAlpha(120), blurRadius: 6),
          ],
        ),
        child: Icon(
          Icons.local_fire_department_rounded,
          size: tileSize * 0.2,
          color: Colors.yellow,
        ),
      ),
    );
  }

  // --- Multiplier visuals ---

  Widget _multiplierBackground(double tileSize) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tileSize * 0.12),
        child: Opacity(
          opacity: 0.15,
          child: Center(
            child: Text(
              '×2',
              style: GoogleFonts.spaceGrotesk(
                fontSize: tileSize * 0.6,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF3D2600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _multiplierBadge(double tileSize) {
    return Positioned(
      bottom: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF3D2600),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '×2',
          style: GoogleFonts.spaceGrotesk(
            fontSize: tileSize * 0.14,
            fontWeight: FontWeight.w900,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }

  // --- Wildcard visuals ---

  Widget _wildcardBackground(double tileSize) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tileSize * 0.12),
        child: Opacity(
          opacity: 0.12,
          child: Center(
            child: Icon(
              Icons.star_rounded,
              size: tileSize * 0.7,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _wildcardBadge(double tileSize) {
    return Positioned(
      bottom: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.star_rounded,
          size: tileSize * 0.18,
          color: Colors.white,
        ),
      ),
    );
  }

  // --- Frozen overlay ---

  Widget _frozenOverlay(double tileSize) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.withAlpha(80),
              Colors.blue.withAlpha(60),
            ],
          ),
          borderRadius: BorderRadius.circular(tileSize * 0.12),
          border: Border.all(color: Colors.cyan.withAlpha(180), width: 2),
        ),
        child: Stack(
          children: [
            Positioned(
              top: tileSize * 0.08,
              left: tileSize * 0.08,
              child: Icon(Icons.ac_unit_rounded,
                  size: tileSize * 0.18, color: Colors.cyan.withAlpha(200)),
            ),
            Positioned(
              bottom: tileSize * 0.08,
              right: tileSize * 0.08,
              child: Icon(Icons.ac_unit_rounded,
                  size: tileSize * 0.14, color: Colors.cyan.withAlpha(150)),
            ),
            Positioned(
              top: tileSize * 0.08,
              right: tileSize * 0.08,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.cyan.withAlpha(180),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${tile.frozenTurns}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: tileSize * 0.12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Hammer mode overlay ---

  Widget _hammerOverlay(double tileSize) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(40),
          borderRadius: BorderRadius.circular(tileSize * 0.12),
          border: Border.all(color: AppColors.error, width: 2),
        ),
        child: Icon(
          Icons.close_rounded,
          color: AppColors.error,
          size: tileSize * 0.3,
        ),
      ),
    );
  }
}

class _RadialPatternPainter extends CustomPainter {
  final Color color;

  _RadialPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.5;

    for (double r = maxRadius * 0.3; r <= maxRadius; r += maxRadius * 0.25) {
      canvas.drawCircle(center, r, paint);
    }

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final dx = center.dx + maxRadius * 0.9 * math.cos(angle);
      final dy = center.dy + maxRadius * 0.9 * math.sin(angle);
      canvas.drawLine(center, Offset(dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
