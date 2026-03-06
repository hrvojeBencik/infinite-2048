import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'di.dart';
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
import '../features/levels/data/datasources/levels_local_datasource.dart';
import '../features/levels/domain/entities/level.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/zones',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => sl<LevelsBloc>()..add(const LoadZones()),
          child: const ZoneSelectionPage(),
        );
      },
    ),
    GoRoute(
      path: '/zones/:zoneId/levels',
      builder: (context, state) {
        final zoneId = state.pathParameters['zoneId']!;
        return BlocProvider(
          create: (_) => sl<LevelsBloc>()..add(LoadLevelsForZone(zoneId)),
          child: LevelSelectionPage(zoneId: zoneId),
        );
      },
    ),
    GoRoute(
      path: '/game/:levelId',
      builder: (context, state) {
        final levelId = state.pathParameters['levelId']!;
        final ds = sl<LevelsLocalDataSource>();
        final level = ds.getLevel(levelId);
        if (level == null) {
          return const Scaffold(body: Center(child: Text('Level not found')));
        }
        return BlocProvider(
          create: (_) => sl<GameBloc>()..add(StartGame(level: level)),
          child: GamePage(level: level),
        );
      },
    ),
    GoRoute(
      path: '/challenge/daily',
      builder: (context, state) {
        final achievementsDs = sl<AchievementsLocalDataSource>();
        final challenge = achievementsDs.getDailyChallenge();

        if (challenge.isCompleted) {
          return const Scaffold(
            body: Center(child: Text('Daily challenge already completed!')),
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

        return BlocProvider(
          create: (_) => sl<GameBloc>()
            ..add(StartGame(
              level: dailyLevel,
              undosAvailable: challenge.noUndos ? 0 : 3,
            )),
          child: GamePage(level: dailyLevel, isDailyChallenge: true),
        );
      },
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => sl<AchievementsBloc>()..add(const LoadAchievements()),
          child: const AchievementsPage(),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    if (kDebugMode) ...[
      GoRoute(
        path: '/dev',
        builder: (context, state) => const DevOptionsPage(),
      ),
      GoRoute(
        path: '/dev/game/:levelId',
        builder: (context, state) {
          final levelId = state.pathParameters['levelId']!;
          final ds = sl<LevelsLocalDataSource>();
          final level = ds.getLevel(levelId);
          if (level == null) {
            return const Scaffold(
                body: Center(child: Text('Level not found')));
          }
          return BlocProvider(
            create: (_) => sl<GameBloc>()
              ..add(StartGame(
                level: level,
                undosAvailable: 99,
                hammersAvailable: 10,
                shufflesAvailable: 10,
                mergeBoostsAvailable: 10,
              )),
            child: GamePage(level: level),
          );
        },
      ),
      GoRoute(
        path: '/dev/sandbox',
        builder: (context, state) {
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

          return BlocProvider(
            create: (_) => sl<GameBloc>()
              ..add(StartGame(
                level: sandboxLevel,
                undosAvailable: undos,
                hammersAvailable: hammers,
                shufflesAvailable: shuffles,
                mergeBoostsAvailable: 10,
              )),
            child: GamePage(level: sandboxLevel),
          );
        },
      ),
    ],
  ],
);
