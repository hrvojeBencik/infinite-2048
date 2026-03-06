import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_profile.dart';

class XpBar extends StatelessWidget {
  final PlayerProfile profile;

  const XpBar({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final progress = profile.xpRequiredForNextLevel > 0
        ? profile.xpForCurrentLevel / profile.xpRequiredForNextLevel
        : 1.0;

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
            'Lv ${profile.level}',
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
                  final progressWidth =
                      constraints.maxWidth * progress.clamp(0.0, 1.0);
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${profile.xpForCurrentLevel} / ${profile.xpRequiredForNextLevel}',
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
