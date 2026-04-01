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
import '../../../levels/data/datasources/levels_local_datasource.dart';
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
  String _currentZoneName = 'Genesis';
  String _currentZoneId = 'genesis';
  int _currentLevel = 1;
  int _zoneLevelCount = 10;
  int _zoneCompletedLevels = 0;

  @override
  void initState() {
    super.initState();
    context.read<AchievementsBloc>().add(const LoadAchievements());
    _loadProfile();
  }

  void _loadProfile() {
    final ds = sl<ProgressionLocalDataSource>();
    final levelsDs = sl<LevelsLocalDataSource>();
    setState(() {
      _profile = ds.getProfile();
      _loadCurrentZone(levelsDs);
    });
  }

  void _loadCurrentZone(LevelsLocalDataSource levelsDs) {
    final zones = levelsDs.getZones();
    for (final zone in zones) {
      final levels = levelsDs.getLevelsForZone(zone.id);
      final completed = levels.where((l) => l.isCompleted).length;
      if (completed < levels.length) {
        _currentZoneName = zone.name;
        _currentZoneId = zone.id;
        _zoneLevelCount = levels.length;
        _zoneCompletedLevels = completed;
        _currentLevel = completed + 1;
        return;
      }
    }
    final lastZone = zones.last;
    _currentZoneName = lastZone.name;
    _currentZoneId = lastZone.id;
    _zoneLevelCount = 10;
    _zoneCompletedLevels = 10;
    _currentLevel = 50;
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
                _Header(
                  zoneName: _currentZoneName,
                  zoneId: _currentZoneId,
                  currentLevel: _currentLevel,
                  zoneLevelCount: _zoneLevelCount,
                  zoneCompletedLevels: _zoneCompletedLevels,
                ),
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
                _DailyChallengeCard(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                _PlayButton(
                  onReturn: _refresh,
                  zoneName: _currentZoneName,
                  zoneId: _currentZoneId,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                _EndlessModeButton(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                _WeeklyChallengeCard(
                  onReturn: _refresh,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
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
  final String zoneName;
  final String zoneId;
  final int currentLevel;
  final int zoneLevelCount;
  final int zoneCompletedLevels;

  const _Header({
    required this.zoneName,
    required this.zoneId,
    required this.currentLevel,
    required this.zoneLevelCount,
    required this.zoneCompletedLevels,
  });

  Color _zoneColor() {
    switch (zoneId) {
      case 'genesis': return AppColors.zoneGenesis;
      case 'inferno': return AppColors.zoneInferno;
      case 'glacier': return AppColors.zoneGlacier;
      case 'nexus': return AppColors.zoneNexus;
      case 'void': return AppColors.zoneVoid;
      default: return AppColors.zoneEndless;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoneColor = _zoneColor();
    final progress = zoneLevelCount > 0
        ? zoneCompletedLevels / zoneLevelCount
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MERGE QUEST',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.0,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The Ultimate Number Puzzle',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
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
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: zoneColor.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: zoneColor.withAlpha(40), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: zoneColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Zone: $zoneName',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: zoneColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Level $currentLevel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: zoneColor.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation<Color>(zoneColor),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback? onReturn;
  final String zoneName;
  final String zoneId;

  const _PlayButton({this.onReturn, required this.zoneName, required this.zoneId});

  Color _zoneColor() {
    switch (zoneId) {
      case 'genesis': return AppColors.zoneGenesis;
      case 'inferno': return AppColors.zoneInferno;
      case 'glacier': return AppColors.zoneGlacier;
      case 'nexus': return AppColors.zoneNexus;
      case 'void': return AppColors.zoneVoid;
      default: return AppColors.zoneEndless;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoneColor = _zoneColor();
    return AnimatedButton(
      onPressed: () => context.push('/zones').then((_) => onReturn?.call()),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [zoneColor, zoneColor.withAlpha(180)],
      ),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
            const SizedBox(width: 12),
            Column(
              children: [
                const Text(
                  'CONTINUE QUEST',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  zoneName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
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
                  'No limits -- merge as far as you can',
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

  static String _formatTimeRemaining(DateTime until) {
    final remaining = until.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return 'Resets in ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsBloc, AchievementsState>(
      builder: (context, state) {
        if (state is! AchievementsLoaded || state.dailyChallenge == null) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: SizedBox(
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(60),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }
        final challenge = state.dailyChallenge!;
        final isCompleted = challenge.isCompleted;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: GlassCard(
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
                      if (isCompleted)
                        const Text(
                          'Come back tomorrow for a new challenge.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else ...[
                        Text(
                          'Reach ${challenge.targetTileValue} on a ${challenge.boardSize}x${challenge.boardSize} board',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimeRemaining(challenge.availableUntil),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
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
