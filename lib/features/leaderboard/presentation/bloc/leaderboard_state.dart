part of 'leaderboard_bloc.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {
  final LeaderboardMode mode;
  const LeaderboardLoading({required this.mode});

  @override
  List<Object?> get props => [mode];
}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final LeaderboardMode mode;
  final int? currentUserRank;
  final String? currentUid;

  const LeaderboardLoaded({
    required this.entries,
    required this.mode,
    this.currentUserRank,
    this.currentUid,
  });

  @override
  List<Object?> get props => [entries, mode, currentUserRank, currentUid];
}

class LeaderboardError extends LeaderboardState {
  final String message;
  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
