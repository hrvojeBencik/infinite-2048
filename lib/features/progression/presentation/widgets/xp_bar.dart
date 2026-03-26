import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_profile.dart';

class XpBar extends StatefulWidget {
  final PlayerProfile profile;

  const XpBar({
    super.key,
    required this.profile,
  });

  @override
  State<XpBar> createState() => _XpBarState();
}

class _XpBarState extends State<XpBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  double _computeProgress(PlayerProfile profile) {
    return profile.xpRequiredForNextLevel > 0
        ? profile.xpForCurrentLevel / profile.xpRequiredForNextLevel
        : 1.0;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final progress = _computeProgress(widget.profile).clamp(0.0, 1.0);
    _previousProgress = progress;
    _animation = Tween<double>(begin: 0.0, end: _previousProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(XpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newProgress = _computeProgress(widget.profile).clamp(0.0, 1.0);
    if (newProgress != _previousProgress) {
      _animation = Tween<double>(
        begin: _previousProgress,
        end: newProgress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
      _previousProgress = newProgress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withAlpha(100),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Lv ${widget.profile.level}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final progressWidth =
                          constraints.maxWidth * _animation.value;
                      return Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.background.withAlpha(150),
                            ),
                          ),
                          SizedBox(
                            width: progressWidth,
                            height: 10,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${widget.profile.xpForCurrentLevel} / ${widget.profile.xpRequiredForNextLevel}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
