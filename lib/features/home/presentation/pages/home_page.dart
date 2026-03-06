import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_badge.dart';
import '../../../achievements/presentation/bloc/achievements_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import '../../../progression/data/datasources/progression_local_datasource.dart';
import '../../../progression/domain/entities/player_profile.dart';
import '../../../progression/presentation/widgets/streak_calendar.dart';
import '../../../progression/presentation/widgets/xp_bar.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';

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
                const SizedBox(height: 16),
                _PremiumBanner()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.1),
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
                const SizedBox(height: 32),
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
                backgroundColor: AppColors.surface,
                backgroundImage:
                    state is AuthAuthenticated && state.user.photoUrl != null
                    ? NetworkImage(state.user.photoUrl!)
                    : null,
                child:
                    state is! AuthAuthenticated || state.user.photoUrl == null
                    ? const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.textTertiary,
                        size: 22,
                      )
                    : null,
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
      _showLoginPrompt(context);
    }
  }

  void _showLoginPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _LoginBottomSheet(),
      ),
    );
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

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded && state.isPremium) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: () => context.push('/paywall'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(20),
                  AppColors.primary.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withAlpha(40)),
            ),
            child: Row(
              children: [
                const PremiumBadge(size: 24),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ad-free, unlimited undos & more',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoginBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pop();
          context.push('/leaderboard', extra: state.user.uid);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.leaderboard_rounded,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign In to Access\nthe Leaderboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compete with players worldwide and\ntrack your ranking across all modes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return Column(
                  children: [
                    AnimatedButton(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const AuthGoogleSignInRequested()),
                      backgroundColor: Colors.white,
                      gradient: null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            width: 20,
                            height: 20,
                            errorBuilder: (_, _, _) => const Icon(
                                Icons.g_mobiledata,
                                size: 20,
                                color: Colors.black87),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 12),
                      AnimatedButton(
                        onPressed: () => context
                            .read<AuthBloc>()
                            .add(const AuthAppleSignInRequested()),
                        backgroundColor: Colors.white,
                        gradient: null,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.apple,
                                size: 22, color: Colors.black87),
                            SizedBox(width: 12),
                            Text(
                              'Continue with Apple',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Maybe later',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
