part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GamePlaying extends GameState {
  final GameSession session;
  final Level level;

  const GamePlaying({required this.session, required this.level});

  @override
  List<Object?> get props => [session, level];
}

class GameWon extends GameState {
  final GameSession session;
  final Level level;
  final int stars;

  const GameWon({
    required this.session,
    required this.level,
    required this.stars,
  });

  @override
  List<Object?> get props => [session, level, stars];
}

class GameLost extends GameState {
  final GameSession session;
  final Level level;

  const GameLost({required this.session, required this.level});

  @override
  List<Object?> get props => [session, level];
}
