import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../bloc/leaderboard_bloc.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textPrimary,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ModeFilterBar(),
              const SizedBox(height: 16),
              Expanded(child: _LeaderboardContent()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeFilterBar extends StatelessWidget {
  static const _modes = [
    (LeaderboardMode.endless, 'Endless'),
    (LeaderboardMode.story, 'Story'),
    (LeaderboardMode.daily, 'Daily'),
    (LeaderboardMode.weekly, 'Weekly'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      buildWhen: (prev, curr) {
        final prevMode = prev is LeaderboardLoaded
            ? prev.mode
            : prev is LeaderboardLoading
                ? prev.mode
                : null;
        final currMode = curr is LeaderboardLoaded
            ? curr.mode
            : curr is LeaderboardLoading
                ? curr.mode
                : null;
        return prevMode != currMode;
      },
      builder: (context, state) {
        final activeMode = state is LeaderboardLoaded
            ? state.mode
            : state is LeaderboardLoading
                ? state.mode
                : LeaderboardMode.endless;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _modes.map((entry) {
              final isActive = activeMode == entry.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<LeaderboardBloc>()
                      .add(ChangeLeaderboardMode(entry.$1)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withAlpha(30)
                          : AppColors.surface.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary.withAlpha(120)
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      entry.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is LeaderboardLoaded) {
          if (state.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard_rounded,
                      size: 64, color: AppColors.textTertiary.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text(
                    'No scores yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Be the first to set a record!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (state.currentUserRank != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: GlassCard(
                    borderColor: AppColors.primary.withAlpha(60),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Your Rank',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '#${state.currentUserRank}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: state.entries.length,
                  itemBuilder: (context, index) {
                    return _LeaderboardRow(
                      entry: state.entries[index],
                      rank: index + 1,
                      isCurrentUser:
                          state.entries[index].uid == state.currentUid,
                    )
                        .animate(delay: (index * 30).ms)
                        .fadeIn(duration: 200.ms)
                        .slideX(begin: 0.05, duration: 200.ms);
                  },
                ),
              ),
            ],
          );
        }

        if (state is LeaderboardError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.entry,
    required this.rank,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withAlpha(20)
            : AppColors.surface.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primary.withAlpha(60)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: rank <= 3
                ? Icon(
                    Icons.emoji_events_rounded,
                    color: _medalColor(rank),
                    size: 22,
                  )
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            backgroundImage: entry.photoUrl != null
                ? NetworkImage(entry.photoUrl!)
                : null,
            child: entry.photoUrl == null
                ? Text(
                    entry.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.highestTile > 0)
                  Text(
                    'Best tile: ${entry.highestTile}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatScore(entry.score),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: rank <= 3 ? _medalColor(rank) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.secondary;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textTertiary;
    }
  }

  String _formatScore(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
