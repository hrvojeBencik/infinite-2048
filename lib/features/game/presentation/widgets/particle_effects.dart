import 'dart:math';

import 'package:flutter/material.dart';

class ParticleEffect extends StatefulWidget {
  const ParticleEffect({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  State<ParticleEffect> createState() => ParticleEffectState();
}

class ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Particle> _particles = [];
  final Random _random = Random();

  static const List<Color> _particleColors = [
    Color(0xFF6C63FF),   // AppColors.primary (purple)
    Color(0xFF8B83FF),   // AppColors.primaryLight
    Color(0xFFFFD700),   // AppColors.secondary (gold)
    Color(0xFFFF6B6B),   // coral (from confetti palette)
    Color(0xFF48DBFB),   // cyan (from confetti palette)
    Color(0xFFFFAB40),   // amber accent (warm contrast)
    Color(0xFFFFFFFF),   // white spark
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void explode() {
    _particles = List.generate(30, (i) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 60 + _random.nextDouble() * 180;
      final color = _particleColors[_random.nextInt(_particleColors.length)];
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        color: color,
        size: 3 + _random.nextDouble() * 7,
        // Gravity simulation: heavier particles fall faster
        gravity: 40 + _random.nextDouble() * 80,
        // Rotation for visual variety
        rotationSpeed: (_random.nextDouble() - 0.5) * 6,
        // Some particles are "sparks" (smaller, brighter, faster fade)
        isSpark: i % 4 == 0,
      );
    });
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
    required this.gravity,
    required this.rotationSpeed,
    required this.isSpark,
  });

  final double dx;
  final double dy;
  final Color color;
  final double size;
  final double gravity;
  final double rotationSpeed;
  final bool isSpark;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final distance = Curves.easeOutCubic.transform(progress);
      final x = center.dx + particle.dx * distance;
      // Add gravity effect - particles arc downward
      final y = center.dy + particle.dy * distance + particle.gravity * progress * progress;

      // Sparks fade faster
      final fadeStart = particle.isSpark ? 0.3 : 0.5;
      final opacity = progress < fadeStart
          ? 1.0
          : (1.0 - ((progress - fadeStart) / (1.0 - fadeStart))).clamp(0.0, 1.0);

      final effectiveSize = particle.isSpark
          ? particle.size * (1 - progress * 0.8)
          : particle.size * (1 - progress * 0.4);

      if (effectiveSize <= 0 || opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Draw main particle
      canvas.drawCircle(Offset(x, y), effectiveSize.clamp(0.5, 20.0), paint);

      // Draw subtle glow around larger particles
      if (!particle.isSpark && effectiveSize > 3) {
        final glowPaint = Paint()
          ..color = particle.color.withValues(alpha: opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), effectiveSize * 1.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}
