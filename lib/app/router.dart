import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'di.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/levels/presentation/pages/zone_selection_page.dart';
import '../features/levels/presentation/pages/level_selection_page.dart';
import '../features/game/presentation/pages/game_page.dart';
import '../features/game/presentation/bloc/game_bloc.dart';
import '../features/levels/presentation/bloc/levels_bloc.dart';
import '../features/achievements/presentation/pages/achievements_page.dart';
import '../features/achievements/presentation/bloc/achievements_bloc.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/subscription/presentation/pages/paywall_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/levels/data/datasources/levels_local_datasource.dart';

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
        final ds = sl<LevelsLocalDataSource>();
        // Use first genesis level as fallback for daily challenge structure
        final dummyLevel = ds.getLevel('genesis_1');
        if (dummyLevel == null) {
          return const Scaffold(body: Center(child: Text('Not available')));
        }
        return BlocProvider(
          create: (_) => sl<GameBloc>()..add(StartGame(level: dummyLevel)),
          child: GamePage(level: dummyLevel),
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
  ],
);
