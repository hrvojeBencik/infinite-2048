import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/leaderboard_remote_datasource.dart';
import '../../domain/entities/leaderboard_entry.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRemoteDataSource dataSource;

  LeaderboardBloc({required this.dataSource}) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoad);
    on<ChangeLeaderboardMode>(_onChangeMode);
  }

  Future<void> _onLoad(
      LoadLeaderboard event, Emitter<LeaderboardState> emit) async {
    emit(LeaderboardLoading(mode: event.mode));
    final entries = await dataSource.getTopScores(mode: event.mode);
    final rank = event.currentUid != null
        ? await dataSource.getUserRank(
            uid: event.currentUid!, mode: event.mode)
        : null;
    emit(LeaderboardLoaded(
      entries: entries,
      mode: event.mode,
      currentUserRank: rank,
      currentUid: event.currentUid,
    ));
  }

  Future<void> _onChangeMode(
      ChangeLeaderboardMode event, Emitter<LeaderboardState> emit) async {
    final currentUid =
        state is LeaderboardLoaded ? (state as LeaderboardLoaded).currentUid : null;
    add(LoadLeaderboard(mode: event.mode, currentUid: currentUid));
  }
}
