import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'di.dart';
import '../core/services/analytics_service.dart';
import '../features/dev/presentation/pages/dev_options_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/levels/presentation/pages/zone_selection_page.dart';
import '../features/levels/presentation/pages/level_selection_page.dart';
import '../features/game/presentation/pages/game_page.dart';
import '../features/game/presentation/bloc/game_bloc.dart';
import '../features/game/domain/entities/special_tile_type.dart';
import '../features/levels/presentation/bloc/levels_bloc.dart';
import '../features/achievements/presentation/pages/achievements_page.dart';
import '../features/achievements/presentation/bloc/achievements_bloc.dart';
import '../features/achievements/data/datasources/achievements_local_datasource.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/subscription/presentation/pages/paywall_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/progression/presentation/pages/theme_selection_page.dart';
import '../features/statistics/presentation/pages/statistics_page.dart';
import '../features/endless/presentation/bloc/endless_bloc.dart';
import '../features/endless/presentation/pages/endless_game_page.dart';
import '../features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import '../features/leaderboard/presentation/pages/leaderboard_page.dart';
import '../features/leaderboard/domain/entities/leaderboard_entry.dart';
import '../features/levels/data/datasources/levels_local_datasource.dart';
import '../features/levels/domain/entities/level.dart';
import '../features/subscription/presentation/bloc/subscription_bloc.dart';

bool _isPremium(BuildContext context) {
  try {
    final state = context.read<SubscriptionBloc>().state;
    return state is SubscriptionLoaded && state.isPremium;
  } catch (_) {
    return false;
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _buildTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  observers: [
    if (sl.isRegistered<AnalyticsService>() &&
        sl<AnalyticsService>().observer != null)
      sl<AnalyticsService>().observer!,
  ],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/zones',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: BlocProvider(
          create: (_) => sl<LevelsBloc>()..add(const LoadZones()),
          child: const ZoneSelectionPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/zones/:zoneId/levels',
      pageBuilder: (context, state) {
        final zoneId = state.pathParameters['zoneId']!;
        return _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<LevelsBloc>()..add(LoadLevelsForZone(zoneId)),
            child: LevelSelectionPage(zoneId: zoneId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/game/:levelId',
      pageBuilder: (context, state) {
        final levelId = state.pathParameters['levelId']!;
        final ds = sl<LevelsLocalDataSource>();
        final level = ds.getLevel(levelId);
        if (level == null) {
          return _buildTransitionPage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Level not found'))),
          );
        }
        final premium = _isPremium(context);
        return _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<GameBloc>()
              ..add(StartGame(
                level: level,
                undosAvailable: premium ? 99 : 3,
                hammersAvailable: premium ? 5 : 0,
                shufflesAvailable: premium ? 3 : 0,
                mergeBoostsAvailable: premium ? 3 : 0,
              )),
            child: GamePage(level: level),
          ),
        );
      },
    ),
    GoRoute(
      path: '/challenge/daily',
      pageBuilder: (context, state) {
        final achievementsDs = sl<AchievementsLocalDataSource>();
        final challenge = achievementsDs.getDailyChallenge();

        if (challenge.isCompleted) {
          return _buildTransitionPage(
            state: state,
            child: const Scaffold(
              body: Center(child: Text('Daily challenge already completed!')),
            ),
          );
        }

        final dailyLevel = Level(
          id: 'daily_challenge',
          zoneId: 'daily',
          levelNumber: 0,
          boardSize: challenge.boardSize,
          targetTileValue: challenge.targetTileValue,
          moveLimit: challenge.moveLimit,
          timeLimitSeconds: challenge.timeLimitSeconds,
          starThreshold2: challenge.targetTileValue * 2,
          starThreshold3: challenge.targetTileValue * 4,
        );

        final premium = _isPremium(context);
        return _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<GameBloc>()
              ..add(StartGame(
                level: dailyLevel,
                undosAvailable: challenge.noUndos ? 0 : (premium ? 99 : 3),
                hammersAvailable: premium ? 5 : 0,
                shufflesAvailable: premium ? 3 : 0,
                mergeBoostsAvailable: premium ? 3 : 0,
              )),
            child: GamePage(level: dailyLevel, isDailyChallenge: true),
          ),
        );
      },
    ),
    GoRoute(
      path: '/challenge/weekly',
      pageBuilder: (context, state) {
        final achievementsDs = sl<AchievementsLocalDataSource>();
        final challenge = achievementsDs.getWeeklyChallenge();

        if (challenge.isCompleted) {
          return _buildTransitionPage(
            state: state,
            child: const Scaffold(
              body: Center(child: Text('Weekly challenge already completed!')),
            ),
          );
        }

        final weeklyLevel = Level(
          id: 'weekly_challenge',
          zoneId: 'weekly',
          levelNumber: 0,
          boardSize: challenge.boardSize,
          targetTileValue: challenge.targetTileValue,
          moveLimit: challenge.moveLimit,
          timeLimitSeconds: challenge.timeLimitSeconds,
          starThreshold2: challenge.targetTileValue * 2,
          starThreshold3: challenge.targetTileValue * 4,
        );

        final premium = _isPremium(context);
        return _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<GameBloc>()
              ..add(StartGame(
                level: weeklyLevel,
                undosAvailable: challenge.noUndos ? 0 : (premium ? 99 : 3),
                hammersAvailable: premium ? 5 : 0,
                shufflesAvailable: premium ? 3 : 0,
                mergeBoostsAvailable: premium ? 3 : 0,
              )),
            child: GamePage(level: weeklyLevel, isDailyChallenge: false),
          ),
        );
      },
    ),
    GoRoute(
      path: '/themes',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const ThemeSelectionPage(),
      ),
    ),
    GoRoute(
      path: '/endless',
      pageBuilder: (context, state) {
        final premium = _isPremium(context);
        return _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<EndlessBloc>()
              ..add(StartEndless(undosAvailable: premium ? 99 : 3)),
            child: const EndlessGamePage(),
          ),
        );
      },
    ),
    GoRoute(
      path: '/statistics',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const StatisticsPage(),
      ),
    ),
    if (sl.isRegistered<LeaderboardBloc>())
      GoRoute(
        path: '/leaderboard',
        pageBuilder: (context, state) {
          final uid = state.extra as String?;
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => sl<LeaderboardBloc>()
                ..add(LoadLeaderboard(
                  mode: LeaderboardMode.endless,
                  currentUid: uid,
                )),
              child: const LeaderboardPage(),
            ),
          );
        },
      ),
    GoRoute(
      path: '/achievements',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: BlocProvider(
          create: (_) => sl<AchievementsBloc>()..add(const LoadAchievements()),
          child: const AchievementsPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const ProfilePage(),
      ),
    ),
    GoRoute(
      path: '/paywall',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const PaywallPage(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const SettingsPage(),
      ),
    ),
    if (kDebugMode) ...[
      GoRoute(
        path: '/dev',
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: const DevOptionsPage(),
        ),
      ),
      GoRoute(
        path: '/dev/game/:levelId',
        pageBuilder: (context, state) {
          final levelId = state.pathParameters['levelId']!;
          final ds = sl<LevelsLocalDataSource>();
          final level = ds.getLevel(levelId);
          if (level == null) {
            return _buildTransitionPage(
              state: state,
              child: const Scaffold(
                  body: Center(child: Text('Level not found'))),
            );
          }
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => sl<GameBloc>()
                ..add(StartGame(
                  level: level,
                  undosAvailable: 99,
                  hammersAvailable: 10,
                  shufflesAvailable: 10,
                  mergeBoostsAvailable: 10,
                )),
              child: GamePage(level: level),
            ),
          );
        },
      ),
      GoRoute(
        path: '/dev/sandbox',
        pageBuilder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          final boardSize = params['boardSize'] as int? ?? 4;
          final target = params['target'] as int? ?? 2048;
          final undos = params['undos'] as int? ?? 99;
          final hammers = params['hammers'] as int? ?? 10;
          final shuffles = params['shuffles'] as int? ?? 10;
          final spawnRates =
              params['spawnRates'] as Map<SpecialTileType, double>? ?? {};

          final sandboxLevel = Level(
            id: 'dev_sandbox',
            zoneId: 'dev',
            levelNumber: 0,
            boardSize: boardSize,
            targetTileValue: target,
            specialTileSpawnRates: spawnRates,
            starThreshold2: target * 2,
            starThreshold3: target * 4,
          );

          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => sl<GameBloc>()
                ..add(StartGame(
                  level: sandboxLevel,
                  undosAvailable: undos,
                  hammersAvailable: hammers,
                  shufflesAvailable: shuffles,
                  mergeBoostsAvailable: 10,
                )),
              child: GamePage(level: sandboxLevel),
            ),
          );
        },
      ),
    ],
  ],
);
