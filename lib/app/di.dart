import 'package:get_it/get_it.dart';

import '../core/services/ad_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/haptic_service.dart';
import '../core/services/mechanic_intro_service.dart';
import '../core/services/rate_app_service.dart';
import '../core/services/remote_config_service.dart';
import '../core/services/sound_service.dart';
import '../features/achievements/data/datasources/achievements_local_datasource.dart';
import '../features/achievements/data/repositories/achievements_repository_impl.dart';
import '../features/achievements/domain/repositories/achievements_repository.dart';
import '../features/achievements/presentation/bloc/achievements_bloc.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/endless/data/datasources/endless_local_datasource.dart';
import '../features/endless/presentation/bloc/endless_bloc.dart';
import '../features/game/data/datasources/game_local_datasource.dart';
import '../features/game/data/repositories/game_repository_impl.dart';
import '../features/game/domain/repositories/game_repository.dart';
import '../features/game/presentation/bloc/game_bloc.dart';
import '../features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import '../features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import '../features/levels/data/datasources/levels_local_datasource.dart';
import '../features/levels/data/repositories/levels_repository_impl.dart';
import '../features/levels/domain/repositories/levels_repository.dart';
import '../features/levels/presentation/bloc/levels_bloc.dart';
import '../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../features/progression/data/datasources/progression_local_datasource.dart';
import '../features/progression/presentation/bloc/progression_bloc.dart';
import '../features/statistics/data/datasources/statistics_local_datasource.dart';
import '../features/subscription/data/services/subscription_service.dart';
import '../features/subscription/presentation/bloc/subscription_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  sl.registerLazySingleton<AdService>(() => AdService());
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  sl.registerLazySingleton<HapticService>(() => HapticService());
  sl.registerLazySingleton<MechanicIntroService>(() => MechanicIntroService());
  sl.registerLazySingleton<SoundService>(() => SoundService());
  sl.registerLazySingleton<RateAppService>(() => RateAppService());
  sl.registerLazySingleton<RemoteConfigService>(() => RemoteConfigService());
  sl.registerLazySingleton<SubscriptionService>(() => SubscriptionService());

  // Data sources
  sl.registerLazySingleton<GameLocalDataSource>(() => GameLocalDataSource());
  sl.registerLazySingleton<LevelsLocalDataSource>(
    () => LevelsLocalDataSource(),
  );
  sl.registerLazySingleton<AchievementsLocalDataSource>(
    () => AchievementsLocalDataSource(),
  );
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSource(),
  );
  sl.registerLazySingleton<ProgressionLocalDataSource>(
    () => ProgressionLocalDataSource(),
  );
  sl.registerLazySingleton<StatisticsLocalDataSource>(
    () => StatisticsLocalDataSource(),
  );
  sl.registerLazySingleton<EndlessLocalDataSource>(
    () => EndlessLocalDataSource(),
  );

  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LevelsRepository>(
    () => LevelsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<AchievementsRepository>(
    () => AchievementsRepositoryImpl(localDataSource: sl()),
  );

  // Auth (only if Firebase is available)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // BLoCs
  sl.registerFactory<GameBloc>(
    () => GameBloc(
      repository: sl(),
      progressionDataSource: sl<ProgressionLocalDataSource>(),
    ),
  );
  sl.registerFactory<LevelsBloc>(() => LevelsBloc(repository: sl()));
  sl.registerFactory<AchievementsBloc>(
    () => AchievementsBloc(repository: sl()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: sl<AuthRepository>(),
      leaderboardDataSource: sl<LeaderboardRemoteDataSource>(),
    ),
  );
  sl.registerFactory<EndlessBloc>(
    () => EndlessBloc(dataSource: sl<EndlessLocalDataSource>()),
  );

  sl.registerFactory<LeaderboardBloc>(
    () => LeaderboardBloc(dataSource: sl<LeaderboardRemoteDataSource>()),
  );

  sl.registerLazySingleton<ProgressionBloc>(
    () => ProgressionBloc(dataSource: sl<ProgressionLocalDataSource>()),
  );

  sl.registerLazySingleton<SubscriptionBloc>(
    () => SubscriptionBloc(service: sl<SubscriptionService>()),
  );
}
