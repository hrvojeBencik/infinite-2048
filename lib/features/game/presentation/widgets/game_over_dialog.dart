import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int highestTile;
  final VoidCallback onRetry;
  final VoidCallback onBackToLevels;
  final VoidCallback? onWatchAdToContinue;
  final bool isPremium;
  final VoidCallback? onUpgrade;
  final VoidCallback? onContinuePremium;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highestTile,
    required this.onRetry,
    required this.onBackToLevels,
    this.onWatchAdToContinue,
    this.isPremium = false,
    this.onUpgrade,
    this.onContinuePremium,
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
          border: Border.all(color: AppColors.error.withAlpha(60)),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withAlpha(20),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 56,
              color: AppColors.error.withAlpha(180),
            ).animate().fadeIn(duration: 300.ms).shake(delay: 300.ms),
            const SizedBox(height: 16),
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(label: 'Score', value: score.toString()),
                _StatChip(label: 'Best Tile', value: highestTile.toString()),
              ],
            ),
            const SizedBox(height: 20),
            // Premium continue (no ad needed)
            if (onContinuePremium != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedButton(
                  onPressed: onContinuePremium!,
                  gradient: AppColors.premiumGradient,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_outline_rounded,
                          size: 20, color: AppColors.background),
                      const SizedBox(width: 8),
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Watch ad to continue (free users)
            if (onContinuePremium == null && onWatchAdToContinue != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedButton(
                  onPressed: onWatchAdToContinue!,
                  gradient: AppColors.premiumGradient,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline_rounded,
                          size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Watch Ad to Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Premium upsell for free users
            if (!isPremium && onUpgrade != null)
              _PremiumUpsellCard(onUpgrade: onUpgrade!)
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2),
            if (!isPremium && onUpgrade != null) const SizedBox(height: 12),
            AnimatedButton(
              onPressed: onRetry,
              gradient: AppColors.primaryGradient,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onBackToLevels,
              child: const Text('Back to Levels'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumUpsellCard extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _PremiumUpsellCard({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpgrade,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withAlpha(50)),
        ),
        child: Column(
          children: [
            const Text(
              'Power up your game',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BenefitPill(icon: Icons.undo_rounded, label: '99 Undos'),
                const SizedBox(width: 8),
                _BenefitPill(icon: Icons.gavel_rounded, label: '5 Hammers'),
                const SizedBox(width: 8),
                _BenefitPill(icon: Icons.shuffle_rounded, label: 'Shuffle'),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Go Premium',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
