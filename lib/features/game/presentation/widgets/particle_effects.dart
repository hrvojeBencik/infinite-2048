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
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFFFFD700),
    Color(0xFFFF5252),
    Color(0xFFFFAB40),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void explode() {
    _particles = List.generate(20, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80 + _random.nextDouble() * 120;
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        color: _particleColors[_random.nextInt(_particleColors.length)],
        size: 4 + _random.nextDouble() * 6,
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
  });

  final double dx;
  final double dy;
  final Color color;
  final double size;
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
      final distance = Curves.easeOut.transform(progress);
      final x = center.dx + particle.dx * distance;
      final y = center.dy + particle.dy * distance;
      final opacity = (1 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}
