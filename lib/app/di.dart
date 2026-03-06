import 'package:get_it/get_it.dart';
import '../core/services/ad_service.dart';
import '../core/services/mechanic_intro_service.dart';
import '../features/game/data/datasources/game_local_datasource.dart';
import '../features/game/data/repositories/game_repository_impl.dart';
import '../features/game/domain/repositories/game_repository.dart';
import '../features/game/presentation/bloc/game_bloc.dart';
import '../features/levels/data/datasources/levels_local_datasource.dart';
import '../features/levels/data/repositories/levels_repository_impl.dart';
import '../features/levels/domain/repositories/levels_repository.dart';
import '../features/levels/presentation/bloc/levels_bloc.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/achievements/data/datasources/achievements_local_datasource.dart';
import '../features/achievements/data/repositories/achievements_repository_impl.dart';
import '../features/achievements/domain/repositories/achievements_repository.dart';
import '../features/achievements/presentation/bloc/achievements_bloc.dart';
import '../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../features/subscription/domain/repositories/subscription_repository.dart';
import '../features/subscription/presentation/bloc/subscription_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies({required bool firebaseAvailable}) async {
  // Services
  sl.registerLazySingleton<AdService>(() => AdService());
  sl.registerLazySingleton<MechanicIntroService>(() => MechanicIntroService());

  // Data sources
  sl.registerLazySingleton<GameLocalDataSource>(() => GameLocalDataSource());
  sl.registerLazySingleton<LevelsLocalDataSource>(() => LevelsLocalDataSource());
  sl.registerLazySingleton<AchievementsLocalDataSource>(
      () => AchievementsLocalDataSource());

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
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(),
  );

  // Auth (only if Firebase is available)
  if (firebaseAvailable) {
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  }

  // BLoCs
  sl.registerFactory<GameBloc>(() => GameBloc(repository: sl()));
  sl.registerFactory<LevelsBloc>(() => LevelsBloc(repository: sl()));
  sl.registerFactory<AchievementsBloc>(
      () => AchievementsBloc(repository: sl()));
  sl.registerFactory<SubscriptionBloc>(
      () => SubscriptionBloc(repository: sl()));
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(repository: firebaseAvailable ? sl<AuthRepository>() : null),
  );
}
