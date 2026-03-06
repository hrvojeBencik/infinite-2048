import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../domain/entities/tile_theme.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final TileTheme? newlyUnlockedTheme;
  final VoidCallback onClaim;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    this.newlyUnlockedTheme,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
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
              'LEVEL UP!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$newLevel',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            )
                .animate(delay: 200.ms)
                .scale(begin: const Offset(0, 0), curve: Curves.elasticOut)
                .fadeIn(duration: 500.ms),
            if (newlyUnlockedTheme != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withAlpha(60),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'New Theme Unlocked',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          newlyUnlockedTheme!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background.withAlpha(150),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _RewardRow(icon: Icons.undo_rounded, text: '+3 Undos'),
                  const SizedBox(height: 8),
                  _RewardRow(icon: Icons.build_rounded, text: '+1 Hammer'),
                ],
              ),
            ).animate(delay: 500.ms).fadeIn(),
            const SizedBox(height: 24),
            AnimatedButton(
              onPressed: onClaim,
              gradient: AppColors.primaryGradient,
              child: const Text(
                'Claim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RewardRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.success, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
