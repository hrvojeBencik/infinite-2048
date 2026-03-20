import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tile_themes.dart';
import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
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
                    Text(
                      'Zones',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    BlocBuilder<LevelsBloc, LevelsState>(
                      builder: (context, state) {
                        final stars =
                            state is ZonesLoaded ? state.totalStars : 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.secondary.withAlpha(40)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.secondary, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$stars',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
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
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
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
                              .slideX(begin: 0.08);
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
    final progress = zone.completionPercentage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () {
                try { sl<AnalyticsService>().logZoneSelected(zoneId: zone.id); } catch (_) {}
                context.push('/zones/${zone.id}/levels').then((_) {
                  if (context.mounted) {
                    context.read<LevelsBloc>().add(const LoadZones());
                  }
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isLocked
                  ? [
                      AppColors.surface.withAlpha(80),
                      AppColors.surface.withAlpha(60),
                    ]
                  : [
                      AppColors.surface.withAlpha(180),
                      colors[0].withAlpha(12),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLocked
                  ? AppColors.cardBorder.withAlpha(40)
                  : colors[0].withAlpha(40),
              width: 1,
            ),
            boxShadow: !isLocked
                ? [
                    BoxShadow(
                      color: colors[0].withAlpha(15),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: isLocked ? 0.45 : 1.0,
            child: Column(
              children: [
                Row(
                  children: [
                    // Zone icon with gradient
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors[0].withAlpha(isLocked ? 80 : 200),
                            colors[1].withAlpha(isLocked ? 60 : 160),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: !isLocked
                            ? [
                                BoxShadow(
                                  color: colors[0].withAlpha(40),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _zoneIcon(zone.id),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Zone info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            zone.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right side: lock or chevron
                    if (isLocked)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withAlpha(120),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded,
                                color: AppColors.textTertiary, size: 18),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 12, color: AppColors.textTertiary),
                              const SizedBox(width: 2),
                              Text(
                                '${zone.requiredStarsToUnlock}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors[0].withAlpha(120),
                        size: 28,
                      ),
                  ],
                ),
                if (!isLocked) ...[
                  const SizedBox(height: 14),
                  // Progress section
                  Row(
                    children: [
                      Text(
                        '${zone.completedLevels}/${zone.levels.length} levels',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors[0].withAlpha(200),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 14,
                              color: AppColors.secondary.withAlpha(200)),
                          const SizedBox(width: 3),
                          Text(
                            '${zone.totalStars}/${zone.maxStars}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Fill
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: colors),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors[0].withAlpha(60),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
