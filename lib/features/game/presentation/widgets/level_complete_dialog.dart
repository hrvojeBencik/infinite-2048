import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';

class LevelCompleteDialog extends StatelessWidget {
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
              'LEVEL COMPLETE!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final filled = i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: filled ? AppColors.secondary : AppColors.textTertiary,
                  )
                      .animate(delay: (200 + i * 200).ms)
                      .scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 500.ms),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background.withAlpha(150),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ).animate(delay: 600.ms).fadeIn(),
            const SizedBox(height: 28),
            AnimatedButton(
              onPressed: onNextLevel,
              gradient: AppColors.primaryGradient,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                ],
              ),
            ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onReplay,
                  child: const Text('Replay'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onBackToLevels,
                  child: const Text('Levels'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
