import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/special_tile_type.dart';

class MechanicIntroDialog extends StatefulWidget {
  final List<SpecialTileType> newMechanics;
  final VoidCallback onDismiss;

  const MechanicIntroDialog({
    super.key,
    required this.newMechanics,
    required this.onDismiss,
  });

  @override
  State<MechanicIntroDialog> createState() => _MechanicIntroDialogState();
}

class _MechanicIntroDialogState extends State<MechanicIntroDialog> {
  int _currentPage = 0;

  bool get _isLastPage => _currentPage >= widget.newMechanics.length - 1;

  void _next() {
    if (_isLastPage) {
      widget.onDismiss();
    } else {
      setState(() => _currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mechanic = widget.newMechanics[_currentPage];
    final info = _mechanicInfo(mechanic);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: info.accentColor.withAlpha(60), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: info.accentColor.withAlpha(30),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NEW MECHANIC',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: info.accentColor,
                letterSpacing: 3,
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    info.accentColor,
                    info.accentColor.withAlpha(150),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: info.accentColor.withAlpha(60),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(info.icon, size: 40, color: Colors.white),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            Text(
              info.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 12),
            Text(
              info.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: info.accentColor.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: info.accentColor.withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: info.accentColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      info.tip,
                      style: TextStyle(
                        fontSize: 13,
                        color: info.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            if (widget.newMechanics.length > 1) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.newMechanics.length, (i) {
                  return Container(
                    width: i == _currentPage ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? info.accentColor
                          : AppColors.textTertiary.withAlpha(80),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: info.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isLastPage ? 'GOT IT!' : 'NEXT',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  _MechanicInfo _mechanicInfo(SpecialTileType type) {
    switch (type) {
      case SpecialTileType.bomb:
        return const _MechanicInfo(
          title: 'Bomb Tiles',
          description:
              'Bomb tiles explode when merged, destroying all adjacent tiles '
              'and clearing space on the board. Use them strategically to '
              'remove unwanted tiles.',
          tip: 'Merge a bomb tile with any matching tile to trigger the explosion.',
          icon: Icons.local_fire_department_rounded,
          accentColor: AppColors.zoneInferno,
        );
      case SpecialTileType.ice:
        return const _MechanicInfo(
          title: 'Ice Tiles',
          description:
              'Ice tiles are frozen in place and cannot move or merge. '
              'They thaw gradually over 3 turns. Once fully thawed, '
              'they behave like normal tiles again.',
          tip: 'Plan around frozen tiles -- they\'ll free up after 3 moves.',
          icon: Icons.ac_unit_rounded,
          accentColor: AppColors.zoneGlacier,
        );
      case SpecialTileType.multiplier:
        return const _MechanicInfo(
          title: 'Multiplier Tiles',
          description:
              'Multiplier tiles double the score you earn when they are '
              'involved in a merge. They look like regular tiles but with a '
              'golden glow. Stack merges for massive combos!',
          tip: 'Prioritize merging multiplier tiles for huge score boosts.',
          icon: Icons.flash_on_rounded,
          accentColor: AppColors.zoneNexus,
        );
      case SpecialTileType.wildcard:
        return const _MechanicInfo(
          title: 'Wildcard Tiles',
          description:
              'Wildcard tiles can merge with any tile regardless of value. '
              'When merged, the wildcard takes the value of the other tile and '
              'the result is the next power of 2.',
          tip: 'Save wildcards for high-value tiles to maximize your progress.',
          icon: Icons.star_rounded,
          accentColor: AppColors.primary,
        );
      case SpecialTileType.blocker:
        return const _MechanicInfo(
          title: 'Blocker Tiles',
          description:
              'Blocker tiles are immovable obstacles that take up space on '
              'the board. They cannot be moved or merged. Plan your moves '
              'around them carefully.',
          tip: 'Use the Hammer power-up to remove blockers if you get stuck.',
          icon: Icons.block_rounded,
          accentColor: AppColors.textTertiary,
        );
      case SpecialTileType.none:
        return const _MechanicInfo(
          title: 'Standard Tiles',
          description: 'Regular tiles that can be merged.',
          tip: 'Swipe to merge tiles of the same value.',
          icon: Icons.grid_view_rounded,
          accentColor: AppColors.primary,
        );
    }
  }
}

class _MechanicInfo {
  final String title;
  final String description;
  final String tip;
  final IconData icon;
  final Color accentColor;

  const _MechanicInfo({
    required this.title,
    required this.description,
    required this.tip,
    required this.icon,
    required this.accentColor,
  });
}
