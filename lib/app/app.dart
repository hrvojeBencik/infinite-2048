import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import 'di.dart';
import 'router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/achievements/presentation/bloc/achievements_bloc.dart';

class InfiniteApp extends StatelessWidget {
  const InfiniteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<AchievementsBloc>(
          create: (_) => sl<AchievementsBloc>()..add(const LoadAchievements()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Infinite 2048',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
