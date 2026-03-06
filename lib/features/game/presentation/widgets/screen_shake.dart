import 'dart:math';

import 'package:flutter/material.dart';

class ScreenShake extends StatefulWidget {
  const ScreenShake({
    super.key,
    required this.child,
    this.intensity = 8.0,
  });

  final Widget child;
  final double intensity;

  @override
  State<ScreenShake> createState() => ScreenShakeState();
}

class ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void shake() {
    final offsets = <Offset>[
      Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
      Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
      Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
      Offset.zero,
    ];

    _controller.stop();
    _controller.reset();

    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: offsets[0] * widget.intensity,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: offsets[0] * widget.intensity,
          end: offsets[1] * widget.intensity,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: offsets[1] * widget.intensity,
          end: offsets[2] * widget.intensity,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: offsets[2] * widget.intensity,
          end: Offset.zero,
        ),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
