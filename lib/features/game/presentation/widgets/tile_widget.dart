import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tile_themes.dart';
import '../../domain/entities/tile.dart';
import '../../domain/entities/special_tile_type.dart';
import '../../../progression/presentation/bloc/progression_bloc.dart';
import '../../../progression/domain/entities/tile_theme.dart' as domain_theme;
import 'package:google_fonts/google_fonts.dart';

class TileWidget extends StatefulWidget {
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
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with TickerProviderStateMixin {
  late AnimationController _mergeController;
  late AnimationController _spawnController;
  late AnimationController _glowController;

  late Animation<double> _mergeScale;
  late Animation<double> _spawnScale;
  late Animation<double> _spawnFade;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Merge: punchy scale bounce + glow pulse
    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _mergeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.18), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _mergeController,
      curve: Curves.easeOutCubic,
    ));

    // Spawn: scale up from zero with elastic overshoot
    _spawnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _spawnScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.08), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.96), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _spawnController,
      curve: Curves.easeOutCubic,
    ));
    _spawnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _spawnController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Glow pulse on merge
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOut,
    ));

    // Trigger initial animations
    if (widget.tile.wasMerged) {
      _mergeController.forward();
      _glowController.forward();
    } else if (widget.tile.wasSpawned) {
      _spawnController.forward();
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tile.wasMerged && !oldWidget.tile.wasMerged) {
      _mergeController.forward(from: 0.0);
      _glowController.forward(from: 0.0);
    }
    if (widget.tile.wasSpawned && !oldWidget.tile.wasSpawned) {
      _spawnController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _mergeController.dispose();
    _spawnController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileTheme = context.select<ProgressionBloc, domain_theme.TileTheme>((bloc) {
      final s = bloc.state;
      return s is ProgressionLoaded ? s.activeTileTheme : domain_theme.TileThemes.classic;
    });

    final tileSize = widget.cellSize - widget.spacing;

    Widget tileContent = AnimatedBuilder(
      animation: Listenable.merge([_mergeController, _spawnController, _glowController]),
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 1.0;

        if (_mergeController.isAnimating || _mergeController.value > 0 && _mergeController.value < 1) {
          scale = _mergeScale.value;
        } else if (_spawnController.isAnimating || _spawnController.value > 0 && _spawnController.value < 1) {
          scale = _spawnScale.value;
          opacity = _spawnFade.value;
        }

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale.clamp(0.0, 2.0),
            child: _buildTile(tileSize, tileTheme),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return GestureDetector(onTap: widget.onTap, child: tileContent);
    }

    return tileContent;
  }

  Widget _buildTile(double tileSize, domain_theme.TileTheme theme) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = _glowAnimation.value;
        final tileColor = _getTileMainColor(theme);
        final decoration = _tileDecoration(tileSize, theme);

        return Container(
          width: tileSize,
          height: tileSize,
          decoration: decoration.copyWith(
            boxShadow: [
              ...decoration.boxShadow ?? [],
              if (glowIntensity > 0)
                BoxShadow(
                  color: tileColor.withAlpha((120 * glowIntensity).toInt()),
                  blurRadius: 20 * glowIntensity,
                  spreadRadius: 6 * glowIntensity,
                ),
            ],
          ),
          child: Stack(
            children: [
              if (widget.tile.specialType == SpecialTileType.bomb)
                _bombBackground(tileSize),
              if (widget.tile.specialType == SpecialTileType.multiplier)
                _multiplierBackground(tileSize),
              if (widget.tile.specialType == SpecialTileType.wildcard)
                _wildcardBackground(tileSize),
              if (widget.tile.specialType == SpecialTileType.blocker)
                _blockerContent(tileSize)
              else
                _valueContent(tileSize, theme),
              if (widget.tile.specialType == SpecialTileType.bomb)
                _bombBadge(tileSize),
              if (widget.tile.specialType == SpecialTileType.multiplier)
                _multiplierBadge(tileSize),
              if (widget.tile.specialType == SpecialTileType.wildcard)
                _wildcardBadge(tileSize),
              if (widget.tile.isFrozen) _frozenOverlay(tileSize),
              if (widget.isHammerMode) _hammerOverlay(tileSize),
            ],
          ),
        );
      },
    );
  }

  Color _getTileMainColor(domain_theme.TileTheme theme) {
    if (widget.tile.specialType == SpecialTileType.bomb) return const Color(0xFFFF4444);
    if (widget.tile.specialType == SpecialTileType.multiplier) return const Color(0xFFFFD700);
    if (widget.tile.specialType == SpecialTileType.wildcard) return const Color(0xFF6C63FF);
    return theme.colorForValue(widget.tile.value);
  }

  // Dynamic shadow elevation based on tile value
  double _tileElevation() {
    final value = widget.tile.value;
    if (value <= 4) return 2;
    if (value <= 16) return 4;
    if (value <= 64) return 6;
    if (value <= 256) return 8;
    if (value <= 1024) return 10;
    return 14;
  }

  BoxDecoration _tileDecoration(double tileSize, domain_theme.TileTheme theme) {
    final radius = BorderRadius.circular(tileSize * 0.14);
    final elevation = _tileElevation();

    if (widget.tile.specialType == SpecialTileType.blocker) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E1E38), Color(0xFF12122A)],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF444466), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      );
    }

    if (widget.tile.specialType == SpecialTileType.bomb) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF5555), Color(0xFFCC0000)],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFFF7777).withAlpha(180), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.red.withAlpha(40),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      );
    }

    if (widget.tile.specialType == SpecialTileType.multiplier) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE14D), Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFFFE44D).withAlpha(180), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.secondary.withAlpha(30),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      );
    }

    if (widget.tile.specialType == SpecialTileType.wildcard) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB893FF),
            Color(0xFF6C63FF),
            Color(0xFF63B0FF),
            Color(0xFF6C63FF),
            Color(0xFFB893FF),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFD4CFFF).withAlpha(180), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(120),
            blurRadius: 14,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: const Color(0xFF63B0FF).withAlpha(40),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      );
    }

    final baseColor = theme.colorForValue(widget.tile.value);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(baseColor, Colors.white, 0.15)!,
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.12)!,
        ],
      ),
      borderRadius: radius,
      border: Border.all(
        color: Color.lerp(baseColor, Colors.white, 0.2)!.withAlpha(40),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: baseColor.withAlpha((40 + elevation * 5).clamp(0, 255).toInt()),
          blurRadius: elevation * 1.5,
          spreadRadius: elevation * 0.3,
          offset: Offset(0, elevation * 0.4),
        ),
        if (widget.tile.value >= 64)
          BoxShadow(
            color: baseColor.withAlpha(30),
            blurRadius: 16,
            spreadRadius: 2,
          ),
      ],
    );
  }

  Widget _valueContent(double tileSize, domain_theme.TileTheme theme) {
    Color textColor;
    if (widget.tile.specialType == SpecialTileType.bomb ||
        widget.tile.specialType == SpecialTileType.wildcard) {
      textColor = Colors.white;
    } else if (widget.tile.specialType == SpecialTileType.multiplier) {
      textColor = const Color(0xFF3D2600);
    } else {
      textColor = theme.textColorForValue(widget.tile.value);
    }

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(tileSize * 0.08),
          child: Text(
            widget.tile.value.toString(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: TileThemes.tileFontSize(widget.tile.value, tileSize),
              fontWeight: FontWeight.w800,
              color: textColor,
              shadows: widget.tile.value >= 128
                  ? [
                      Shadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _blockerContent(double tileSize) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tileSize * 0.14),
            child: CustomPaint(
              painter: _CrossHatchPainter(
                color: const Color(0xFF333355),
              ),
            ),
          ),
        ),
        Center(
          child: Icon(
            Icons.block_rounded,
            size: tileSize * 0.45,
            color: const Color(0xFF555577),
          ),
        ),
      ],
    );
  }

  // --- Bomb visuals ---

  Widget _bombBackground(double tileSize) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tileSize * 0.14),
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
        borderRadius: BorderRadius.circular(tileSize * 0.14),
        child: Opacity(
          opacity: 0.15,
          child: Center(
            child: Text(
              '\u00d72',
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
          '\u00d72',
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
        borderRadius: BorderRadius.circular(tileSize * 0.14),
        child: Stack(
          children: [
            Center(
              child: Text(
                '?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: tileSize * 0.65,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withAlpha(25),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(tileSize * 0.14),
                  border: Border.all(
                    color: Colors.white.withAlpha(50),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
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
              Colors.cyan.withAlpha(90),
              Colors.lightBlueAccent.withAlpha(70),
              Colors.cyan.withAlpha(80),
            ],
          ),
          borderRadius: BorderRadius.circular(tileSize * 0.14),
          border: Border.all(color: Colors.cyan.withAlpha(200), width: 2.5),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tileSize * 0.14),
                child: CustomPaint(
                  painter: _IceCrackPainter(
                    color: Colors.white.withAlpha(60),
                  ),
                ),
              ),
            ),
            Positioned(
              top: tileSize * 0.06,
              left: tileSize * 0.06,
              child: Icon(Icons.ac_unit_rounded,
                  size: tileSize * 0.2, color: Colors.white.withAlpha(180)),
            ),
            Positioned(
              bottom: tileSize * 0.06,
              right: tileSize * 0.06,
              child: Icon(Icons.ac_unit_rounded,
                  size: tileSize * 0.14, color: Colors.white.withAlpha(120)),
            ),
            Positioned(
              top: tileSize * 0.06,
              right: tileSize * 0.06,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF006DB3),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withAlpha(100),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '${widget.tile.frozenTurns}',
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
          borderRadius: BorderRadius.circular(tileSize * 0.14),
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

class _CrossHatchPainter extends CustomPainter {
  final Color color;

  _CrossHatchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 8.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i + size.height, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IceCrackPainter extends CustomPainter {
  final Color color;

  _IceCrackPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path()
      ..moveTo(cx * 0.3, cy * 0.2)
      ..lineTo(cx * 0.7, cy * 0.6)
      ..lineTo(cx * 1.0, cy * 0.5)
      ..moveTo(cx * 0.7, cy * 0.6)
      ..lineTo(cx * 0.6, cy * 1.1)
      ..lineTo(cx * 0.9, cy * 1.4)
      ..moveTo(cx * 0.6, cy * 1.1)
      ..lineTo(cx * 0.3, cy * 1.3)
      ..moveTo(cx * 1.2, cy * 0.8)
      ..lineTo(cx * 1.5, cy * 1.2)
      ..lineTo(cx * 1.7, cy * 1.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
