import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tile_themes.dart';
import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/level.dart';
import '../bloc/levels_bloc.dart';

class LevelSelectionPage extends StatelessWidget {
  final String zoneId;

  const LevelSelectionPage({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<LevelsBloc, LevelsState>(
                      builder: (context, state) {
                        final zoneName =
                            state is LevelsLoaded ? state.zone.name : '';
                        return Text(
                          zoneName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Zone progress header
              BlocBuilder<LevelsBloc, LevelsState>(
                builder: (context, state) {
                  if (state is! LevelsLoaded) return const SizedBox.shrink();
                  final zone = state.zone;
                  final colors = TileThemes.zoneGradient(zoneId);
                  final completed =
                      state.levels.where((l) => l.isCompleted).length;
                  final total = state.levels.length;
                  final totalStars =
                      state.levels.fold<int>(0, (s, l) => s + l.starsEarned);
                  final maxStars = total * 3;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors[0].withAlpha(18),
                            colors[1].withAlpha(10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: colors[0].withAlpha(30)),
                      ),
                      child: Row(
                        children: [
                          // Progress ring
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: total > 0 ? completed / total : 0,
                                  backgroundColor:
                                      AppColors.surface.withAlpha(150),
                                  valueColor:
                                      AlwaysStoppedAnimation(colors[0]),
                                  strokeWidth: 4,
                                  strokeCap: StrokeCap.round,
                                ),
                                Text(
                                  '$completed',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors[0],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$completed of $total levels complete',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  zone.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Stars earned
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.secondary.withAlpha(30)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 16, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalStars/$maxStars',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms);
                },
              ),
              // Level grid
              Expanded(
                child: BlocBuilder<LevelsBloc, LevelsState>(
                  builder: (context, state) {
                    if (state is LevelsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      );
                    }
                    if (state is LevelsLoaded) {
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: state.levels.length,
                        itemBuilder: (context, index) {
                          return _LevelTile(
                            level: state.levels[index],
                            zoneId: zoneId,
                            isUnlocked:
                                _isLevelUnlocked(state.levels, index),
                          )
                              .animate(delay: (50 * index).ms)
                              .fadeIn(duration: 300.ms)
                              .scale(begin: const Offset(0.8, 0.8));
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

  bool _isLevelUnlocked(List<Level> levels, int index) {
    if (index == 0) return true;
    return levels[index - 1].isCompleted;
  }
}

class _LevelTile extends StatelessWidget {
  final Level level;
  final String zoneId;
  final bool isUnlocked;

  const _LevelTile({
    required this.level,
    required this.zoneId,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TileThemes.zoneGradient(zoneId);

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              try { sl<AnalyticsService>().logLevelSelected(levelId: level.id); } catch (_) {}
              context.push('/game/${level.id}').then((_) {
                if (context.mounted) {
                  context
                      .read<LevelsBloc>()
                      .add(LoadLevelsForZone(zoneId));
                }
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: level.isCompleted
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors[0].withAlpha(25),
                    colors[1].withAlpha(15),
                  ],
                )
              : null,
          color: level.isCompleted
              ? null
              : isUnlocked
                  ? AppColors.surface
                  : AppColors.surface.withAlpha(60),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: level.isCompleted
                ? colors[0].withAlpha(80)
                : isUnlocked
                    ? AppColors.cardBorder.withAlpha(80)
                    : AppColors.cardBorder.withAlpha(30),
            width: level.isCompleted ? 1.5 : 1,
          ),
          boxShadow: level.isCompleted
              ? [
                  BoxShadow(
                    color: colors[0].withAlpha(25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(
                Icons.lock_rounded,
                size: 22,
                color: AppColors.textTertiary.withAlpha(80),
              )
            else ...[
              Text(
                '${level.levelNumber}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color:
                      level.isCompleted ? colors[0] : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final filled = i < level.starsEarned;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      filled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 15,
                      color: filled
                          ? AppColors.secondary
                          : AppColors.textTertiary.withAlpha(60),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
