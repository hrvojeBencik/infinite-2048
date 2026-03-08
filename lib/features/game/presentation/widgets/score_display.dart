import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreDisplay extends StatelessWidget {
  final String label;
  final int value;
  final bool highlight;

  const ScoreDisplay({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withAlpha(30)
            : AppColors.surface.withAlpha(150),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? AppColors.primary.withAlpha(100) : AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          _AnimatedCounter(
            value: value,
            highlight: highlight,
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatefulWidget {
  final int value;
  final bool highlight;

  const _AnimatedCounter({required this.value, required this.highlight});

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;
  late int _currentTarget;

  // Scale bump animation
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentTarget = widget.value;
    _previousValue = widget.value;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = Tween<double>(
      begin: widget.value.toDouble(),
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(_AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value.round();
      _currentTarget = widget.value;

      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: _currentTarget.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final displayValue = _animation.value.round();
        final scale = _controller.isAnimating ? _scaleAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Text(
            _formatNumber(displayValue),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: widget.highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}
