import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tile_themes.dart';
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
                          style: const TextStyle(
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
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<LevelsBloc, LevelsState>(
                  builder: (context, state) {
                    if (state is LevelsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (state is LevelsLoaded) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: state.levels.length,
                        itemBuilder: (context, index) {
                          return _LevelTile(
                            level: state.levels[index],
                            zoneId: zoneId,
                            isUnlocked: _isLevelUnlocked(state.levels, index),
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
      onTap: isUnlocked ? () => context.push('/game/${level.id}') : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.surface : AppColors.surface.withAlpha(80),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: level.isCompleted
                ? colors[0].withAlpha(100)
                : isUnlocked
                    ? AppColors.cardBorder
                    : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: level.isCompleted
              ? [
                  BoxShadow(
                    color: colors[0].withAlpha(30),
                    blurRadius: 8,
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
                size: 20,
                color: AppColors.textTertiary.withAlpha(100),
              )
            else
              Text(
                '${level.levelNumber}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: level.isCompleted ? colors[0] : AppColors.textPrimary,
                ),
              ),
            if (isUnlocked) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final filled = i < level.starsEarned;
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: filled ? AppColors.secondary : AppColors.textTertiary.withAlpha(80),
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
