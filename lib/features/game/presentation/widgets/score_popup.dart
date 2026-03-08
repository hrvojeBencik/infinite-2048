import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class ScorePopupOverlay extends StatefulWidget {
  const ScorePopupOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ScorePopupOverlay> createState() => ScorePopupOverlayState();
}

class ScorePopupOverlayState extends State<ScorePopupOverlay> {
  final List<_ScorePopupEntry> _popups = [];

  void showPopup(int score, {Color? color}) {
    final entry = _ScorePopupEntry(
      score: score,
      color: color ?? AppColors.secondary,
      key: UniqueKey(),
    );
    setState(() {
      _popups.add(entry);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _popups.removeWhere((p) => p.key == entry.key);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._popups.map((entry) => _ScorePopupWidget(
              key: entry.key,
              score: entry.score,
              color: entry.color,
            )),
      ],
    );
  }
}

class _ScorePopupEntry {
  _ScorePopupEntry({
    required this.score,
    required this.color,
    required this.key,
  });

  final int score;
  final Color color;
  final Key key;
}

class _ScorePopupWidget extends StatefulWidget {
  const _ScorePopupWidget({
    super.key,
    required this.score,
    required this.color,
  });

  final int score;
  final Color color;

  @override
  State<_ScorePopupWidget> createState() => _ScorePopupWidgetState();
}

class _ScorePopupWidgetState extends State<_ScorePopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  // Score magnitude determines visual intensity
  double get _magnitude {
    if (widget.score >= 1000) return 1.5;
    if (widget.score >= 500) return 1.3;
    if (widget.score >= 200) return 1.15;
    if (widget.score >= 100) return 1.05;
    return 1.0;
  }

  double get _fontSize {
    if (widget.score >= 1000) return 28;
    if (widget.score >= 500) return 25;
    if (widget.score >= 100) return 22;
    return 20;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: _magnitude), weight: 15),
      TweenSequenceItem(tween: Tween(begin: _magnitude, end: _magnitude * 0.9), weight: 10),
      TweenSequenceItem(tween: Tween(begin: _magnitude * 0.9, end: 1.0), weight: 75),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _floatAnimation = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value.clamp(0.0, 3.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.color.withAlpha(40),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: widget.score >= 100
                            ? [
                                BoxShadow(
                                  color: widget.color.withAlpha(30),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '+${widget.score}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.w800,
                          color: widget.color,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
