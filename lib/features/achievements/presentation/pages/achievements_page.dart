import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/achievement.dart';
import '../bloc/achievements_bloc.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

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
                      'Achievements',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<AchievementsBloc, AchievementsState>(
                  builder: (context, state) {
                    if (state is AchievementsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (state is AchievementsLoaded) {
                      return _AchievementsList(state: state);
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

class _AchievementsList extends StatelessWidget {
  final AchievementsLoaded state;

  const _AchievementsList({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress summary
          GlassCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.unlockedCount} / ${state.totalCount}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: state.totalCount > 0
                            ? state.unlockedCount / state.totalCount
                            : 0,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (final category in AchievementCategory.values) ...[
            _CategorySection(
              category: category,
              achievements: state.byCategory(category),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final AchievementCategory category;
  final List<Achievement> achievements;

  const _CategorySection({required this.category, required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            _categoryName(category),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...achievements.asMap().entries.map((entry) {
          return _AchievementCard(achievement: entry.value)
              .animate(delay: (entry.key * 80).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05);
        }),
      ],
    );
  }

  String _categoryName(AchievementCategory cat) {
    switch (cat) {
      case AchievementCategory.progression:
        return 'PROGRESSION';
      case AchievementCategory.skill:
        return 'SKILL';
      case AchievementCategory.collection:
        return 'COLLECTION';
      case AchievementCategory.streak:
        return 'STREAK';
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      borderColor: achievement.isUnlocked
          ? AppColors.secondary.withAlpha(60)
          : null,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppColors.secondary.withAlpha(30)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              achievement.isUnlocked
                  ? Icons.emoji_events_rounded
                  : Icons.lock_outline_rounded,
              color: achievement.isUnlocked
                  ? AppColors.secondary
                  : AppColors.textTertiary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: achievement.progressPercentage,
                          backgroundColor: AppColors.surface,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.primary),
                          borderRadius: BorderRadius.circular(3),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(achievement.progressPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (achievement.isUnlocked)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}
