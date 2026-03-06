import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/game_session.dart';

class PowerUpBar extends StatelessWidget {
  final GameSession session;
  final bool isHammerMode;
  final VoidCallback onUndo;
  final VoidCallback onHammer;
  final VoidCallback onShuffle;
  final VoidCallback onMergeBoost;

  const PowerUpBar({
    super.key,
    required this.session,
    required this.isHammerMode,
    required this.onUndo,
    required this.onHammer,
    required this.onShuffle,
    required this.onMergeBoost,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PowerUpButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          count: session.undosRemaining,
          onTap: session.undosRemaining > 0 && session.moveHistory.isNotEmpty
              ? onUndo
              : null,
        ),
        _PowerUpButton(
          icon: Icons.gavel_rounded,
          label: 'Hammer',
          count: session.hammersRemaining,
          isActive: isHammerMode,
          onTap: session.hammersRemaining > 0 ? onHammer : null,
        ),
        _PowerUpButton(
          icon: Icons.shuffle_rounded,
          label: 'Shuffle',
          count: session.shufflesRemaining,
          isPremium: true,
          onTap: session.shufflesRemaining > 0 ? onShuffle : null,
        ),
        _PowerUpButton(
          icon: Icons.flash_on_rounded,
          label: 'Boost',
          count: session.mergeBoostsRemaining,
          isPremium: true,
          onTap: session.mergeBoostsRemaining > 0 ? onMergeBoost : null,
        ),
      ],
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isActive;
  final bool isPremium;
  final VoidCallback? onTap;

  const _PowerUpButton({
    required this.icon,
    required this.label,
    required this.count,
    this.isActive = false,
    this.isPremium = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withAlpha(40)
              : enabled
                  ? AppColors.surface.withAlpha(180)
                  : AppColors.surface.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : enabled
                    ? AppColors.cardBorder
                    : Colors.transparent,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive
                      ? AppColors.primary
                      : enabled
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                ),
                if (isPremium)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
