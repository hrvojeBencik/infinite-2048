import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../achievements/presentation/bloc/achievements_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import '../../../progression/data/datasources/progression_local_datasource.dart';
import '../../../progression/domain/entities/player_profile.dart';
import '../../../progression/presentation/widgets/streak_calendar.dart';
import '../../../progression/presentation/widgets/xp_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PlayerProfile _profile = PlayerProfile.fromTotalXp(
    totalXp: 0,
    activeTileThemeId: 'classic',
    unlockedTileThemeIds: const ['classic'],
    loginStreak: 0,
  );

  @override
  void initState() {
    super.initState();
    context.read<AchievementsBloc>().add(const LoadAchievements());
    _loadProfile();
  }

  void _loadProfile() {
    final ds = sl<ProgressionLocalDataSource>();
    setState(() => _profile = ds.getProfile());
  }

  void _refresh() {
    if (!mounted) return;
    _loadProfile();
    context.read<AchievementsBloc>().add(const LoadAchievements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _Header(),
                const SizedBox(height: 16),
                XpBar(
                  profile: _profile,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                if (_profile.loginStreak > 0) ...[
                  const SizedBox(height: 12),
                  StreakCalendar(
                    profile: _profile,
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                ],
                const SizedBox(height: 20),
                _PlayButton(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                _EndlessModeButton(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                _DailyChallengeCard(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                _WeeklyChallengeCard(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2),
                const SizedBox(height: 20),
                _QuickActions(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                const BannerAdWidget(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MERGE QUEST',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
              const Text(
                '2048',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  state is AuthAuthenticated
                      ? state.user.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(
            Icons.settings_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback? onReturn;
  const _PlayButton({this.onReturn});

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: () => context.push('/zones').then((_) => onReturn?.call()),
      gradient: AppColors.primaryGradient,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'PLAY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndlessModeButton extends StatelessWidget {
  final VoidCallback? onReturn;
  const _EndlessModeButton({this.onReturn});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/endless').then((_) => onReturn?.call()),
      borderColor: AppColors.zoneEndless.withAlpha(40),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.zoneEndless,
                  AppColors.zoneEndless.withAlpha(180),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.all_inclusive_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Endless Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Classic 2048 -- play until you get stuck',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final VoidCallback? onReturn;
  const _DailyChallengeCard({this.onReturn});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsBloc, AchievementsState>(
      builder: (context, state) {
        if (state is! AchievementsLoaded || state.dailyChallenge == null) {
          return const SizedBox.shrink();
        }
        final challenge = state.dailyChallenge!;
        final isCompleted = challenge.isCompleted;

        return GlassCard(
          onTap: isCompleted
              ? null
              : () {
                  try { sl<AnalyticsService>().logDailyChallengeStarted(); } catch (_) {}
                  context.push('/challenge/daily').then((_) {
                    onReturn?.call();
                  });
                },
          borderColor: isCompleted
              ? AppColors.success.withAlpha(40)
              : AppColors.secondary.withAlpha(40),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(
                          colors: [
                            AppColors.success,
                            AppColors.success.withAlpha(180),
                          ],
                        )
                      : AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.today_rounded,
                  color: AppColors.background,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'Challenge Complete!' : 'Daily Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCompleted
                          ? 'Come back tomorrow for a new challenge'
                          : challenge.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                )
              else
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback? onReturn;
  const _QuickActions({this.onReturn});

  void _openLeaderboard(BuildContext context) {
    if (!sl.isRegistered<LeaderboardRemoteDataSource>()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leaderboard requires Firebase')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.push('/leaderboard', extra: authState.user.uid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setting up your account...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.emoji_events_rounded,
                label: 'Achievements',
                color: AppColors.secondary,
                onTap: () =>
                    context.push('/achievements').then((_) => onReturn?.call()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.palette_rounded,
                label: 'Themes',
                color: AppColors.primary,
                onTap: () =>
                    context.push('/themes').then((_) => onReturn?.call()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.bar_chart_rounded,
                label: 'Statistics',
                color: AppColors.success,
                onTap: () => context.push('/statistics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.leaderboard_rounded,
                label: 'Leaderboard',
                color: AppColors.zoneNexus,
                onTap: () => _openLeaderboard(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChallengeCard extends StatelessWidget {
  final VoidCallback? onReturn;
  const _WeeklyChallengeCard({this.onReturn});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsBloc, AchievementsState>(
      builder: (context, state) {
        if (state is! AchievementsLoaded || state.weeklyChallenge == null) {
          return const SizedBox.shrink();
        }
        final challenge = state.weeklyChallenge!;
        final isCompleted = challenge.isCompleted;

        return GlassCard(
          onTap: isCompleted
              ? null
              : () {
                  try { sl<AnalyticsService>().logWeeklyChallengeStarted(); } catch (_) {}
                  context.push('/challenge/weekly').then((_) {
                    onReturn?.call();
                  });
                },
          borderColor: isCompleted
              ? AppColors.success.withAlpha(40)
              : AppColors.primary.withAlpha(40),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(
                          colors: [
                            AppColors.success,
                            AppColors.success.withAlpha(180),
                          ],
                        )
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.date_range_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'Weekly Complete!' : 'Weekly Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCompleted
                          ? 'New challenge next Monday'
                          : challenge.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                )
              else
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
            ],
          ),
        );
      },
    );
  }
}
