import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tile_themes.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/zone.dart';
import '../bloc/levels_bloc.dart';

class ZoneSelectionPage extends StatelessWidget {
  const ZoneSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Zones',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    BlocBuilder<LevelsBloc, LevelsState>(
                      builder: (context, state) {
                        final stars = state is ZonesLoaded ? state.totalStars : 0;
                        return Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '$stars',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<LevelsBloc, LevelsState>(
                  builder: (context, state) {
                    if (state is LevelsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (state is ZonesLoaded) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.zones.length,
                        itemBuilder: (context, index) {
                          return _ZoneCard(
                            zone: state.zones[index],
                            totalStars: state.totalStars,
                            index: index,
                          )
                              .animate(delay: (100 * index).ms)
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: 0.1);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final GameZone zone;
  final int totalStars;
  final int index;

  const _ZoneCard({
    required this.zone,
    required this.totalStars,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = totalStars < zone.requiredStarsToUnlock;
    final colors = TileThemes.zoneGradient(zone.id);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: isLocked
          ? null
          : () {
              context.push('/zones/${zone.id}/levels').then((_) {
                if (context.mounted) {
                  context.read<LevelsBloc>().add(const LoadZones());
                }
              });
            },
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _zoneIcon(zone.id),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    zone.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${zone.completedLevels}/${zone.levels.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors[0],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: zone.completionPercentage,
                          backgroundColor: AppColors.surface,
                          valueColor: AlwaysStoppedAnimation(colors[0]),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.secondary.withAlpha(180),
                      ),
                      Text(
                        ' ${zone.totalStars}/${zone.maxStars}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked)
              Column(
                children: [
                  const Icon(Icons.lock_rounded, color: AppColors.textTertiary, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '${zone.requiredStarsToUnlock}★',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  IconData _zoneIcon(String zoneId) {
    switch (zoneId) {
      case 'genesis':
        return Icons.auto_awesome;
      case 'inferno':
        return Icons.local_fire_department;
      case 'glacier':
        return Icons.ac_unit;
      case 'nexus':
        return Icons.flash_on;
      case 'void':
        return Icons.blur_on;
      default:
        return Icons.all_inclusive;
    }
  }
}
