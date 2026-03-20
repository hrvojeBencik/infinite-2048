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
  final VoidCallback onNextLevel;
  final VoidCallback onBackToLevels;
  final VoidCallback onReplay;

  const LevelCompleteDialog({
    super.key,
    required this.score,
    required this.stars,
    required this.levelNumber,
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
  late AnimationController _glowController;
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

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

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
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Confetti layer
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
                size: const Size(320, 460),
              );
            },
          ),
          // Animated glow behind card
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              final glowOpacity =
                  0.15 + (_glowController.value * 0.15);
              return Container(
                width: 300,
                height: 420,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: glowOpacity),
                      blurRadius: 60,
                      spreadRadius: 8,
                    ),
                    if (widget.stars == 3)
                      BoxShadow(
                        color:
                            AppColors.secondary.withValues(alpha: glowOpacity * 0.5),
                        blurRadius: 80,
                        spreadRadius: 4,
                      ),
                  ],
                ),
              );
            },
          ),
          // Main card
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 320,
            ),
            child: Container(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface,
                  AppColors.surface.withValues(alpha: 0.95),
                  AppColors.background.withValues(alpha: 0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.stars == 3
                    ? AppColors.secondary.withAlpha(80)
                    : AppColors.primary.withAlpha(50),
                width: 1.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Level badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Text(
                    'LEVEL ${widget.levelNumber}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                      letterSpacing: 2,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.5),
                const SizedBox(height: 14),
                // Title with shimmer
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: widget.stars == 3
                          ? [
                              AppColors.secondary,
                              AppColors.secondaryLight,
                              AppColors.secondary,
                            ]
                          : [
                              AppColors.textPrimary,
                              AppColors.primaryLight,
                              AppColors.textPrimary,
                            ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    widget.stars == 3 ? 'PERFECT!' : 'COMPLETE!',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.3),
                const SizedBox(height: 24),
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final filled = i < widget.stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _AnimatedStar(
                        filled: filled,
                        delay: 400 + i * 250,
                        index: i,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Score section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withAlpha(15),
                        AppColors.primary.withAlpha(8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withAlpha(30)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SCORE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, _) {
                          return Text(
                            '${_scoreAnimation.value}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn().scale(
                      begin: const Offset(0.9, 0.9),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 28),
                // Next Level button (primary action)
                AnimatedButton(
                  onPressed: widget.onNextLevel,
                  gradient: widget.stars == 3
                      ? AppColors.premiumGradient
                      : AppColors.primaryGradient,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next Level',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 20, color: Colors.white),
                    ],
                  ),
                ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 16),
                // Secondary actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SecondaryActionButton(
                      icon: Icons.replay_rounded,
                      label: 'Replay',
                      onTap: widget.onReplay,
                    ),
                    const SizedBox(width: 12),
                    _SecondaryActionButton(
                      icon: Icons.grid_view_rounded,
                      label: 'Levels',
                      onTap: widget.onBackToLevels,
                    ),
                  ],
                ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
          ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  final bool filled;
  final int delay;
  final int index;

  const _AnimatedStar({
    required this.filled,
    required this.delay,
    required this.index,
  });

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
      begin: AppColors.textTertiary.withAlpha(60),
      end: widget.filled ? AppColors.secondary : AppColors.textTertiary.withAlpha(60),
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
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: widget.filled
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withAlpha(
                            (80 * _scaleAnimation.value).round()),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: Icon(
              widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: widget.index == 1 ? 52 : 44,
              color: _colorAnimation.value,
            ),
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
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.6),
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
