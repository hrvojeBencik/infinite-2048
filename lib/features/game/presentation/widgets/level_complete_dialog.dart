import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';

class LevelCompleteDialog extends StatefulWidget {
  final int score;
  final int stars;
  final int levelNumber;
  final bool isPremium;
  final VoidCallback? onUpgrade;
  final VoidCallback onNextLevel;
  final VoidCallback onBackToLevels;
  final VoidCallback onReplay;

  const LevelCompleteDialog({
    super.key,
    required this.score,
    required this.stars,
    required this.levelNumber,
    this.isPremium = false,
    this.onUpgrade,
    required this.onNextLevel,
    required this.onBackToLevels,
    required this.onReplay,
  });

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scoreController;
  late Animation<int> _scoreAnimation;
  late List<_ConfettiParticle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(
        parent: _scoreController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _particles = List.generate(60, (_) => _ConfettiParticle.random(_random));

    Future.delayed(200.ms, () {
      if (mounted) {
        _confettiController.forward();
        _scoreController.forward();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
                size: const Size(320, 420),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(30),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEVEL COMPLETE!',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final filled = i < widget.stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _AnimatedStar(filled: filled, delay: 400 + i * 250),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background.withAlpha(150),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, _) {
                      return Text(
                        'Score: ${_scoreAnimation.value}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ).animate(delay: 600.ms).fadeIn(),
                if (!widget.isPremium && widget.stars == 1 && widget.onUpgrade != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: widget.onUpgrade,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              size: 14, color: AppColors.secondary.withAlpha(180)),
                          const SizedBox(width: 6),
                          Text(
                            'Premium power-ups could help you get 3 stars',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary.withAlpha(180),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 1200.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 28),
                AnimatedButton(
                  onPressed: widget.onNextLevel,
                  gradient: AppColors.primaryGradient,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          size: 20, color: Colors.white),
                    ],
                  ),
                ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: widget.onReplay,
                      child: const Text('Replay'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: widget.onBackToLevels,
                      child: const Text('Levels'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  final bool filled;
  final int delay;

  const _AnimatedStar({required this.filled, required this.delay});

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.textTertiary,
      end: widget.filled ? AppColors.secondary : AppColors.textTertiary,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 44,
            color: _colorAnimation.value,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;

  const _ConfettiParticle({
    required this.x,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });

  static final _colors = [
    AppColors.secondary,
    AppColors.primary,
    AppColors.success,
    const Color(0xFFFF6B6B),
    const Color(0xFF48DBFB),
    const Color(0xFFFFA502),
    Colors.white,
  ];

  factory _ConfettiParticle.random(Random random) {
    return _ConfettiParticle(
      x: random.nextDouble(),
      velocityX: (random.nextDouble() - 0.5) * 120,
      velocityY: 150 + random.nextDouble() * 250,
      color: _colors[random.nextInt(_colors.length)],
      size: 4 + random.nextDouble() * 6,
      rotation: random.nextDouble() * pi * 2,
      rotationSpeed: (random.nextDouble() - 0.5) * 8,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final t = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final fade = progress > 0.6 ? (1.0 - ((progress - 0.6) / 0.4)) : 1.0;

    for (final p in particles) {
      final x = p.x * size.width + p.velocityX * t;
      final y = -20 + p.velocityY * t;
      final opacity = fade.clamp(0.0, 1.0);

      if (y < 0 || y > size.height + 20) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
