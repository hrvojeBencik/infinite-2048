part of 'leaderboard_bloc.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  final LeaderboardMode mode;
  final String? currentUid;

  const LoadLeaderboard({
    this.mode = LeaderboardMode.endless,
    this.currentUid,
  });

  @override
  List<Object?> get props => [mode, currentUid];
}

class ChangeLeaderboardMode extends LeaderboardEvent {
  final LeaderboardMode mode;

  const ChangeLeaderboardMode(this.mode);

  @override
  List<Object?> get props => [mode];
}
