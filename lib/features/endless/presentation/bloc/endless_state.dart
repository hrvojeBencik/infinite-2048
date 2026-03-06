part of 'endless_bloc.dart';

abstract class EndlessState extends Equatable {
  const EndlessState();

  @override
  List<Object?> get props => [];
}

class EndlessInitial extends EndlessState {}

class EndlessPlaying extends EndlessState {
  final GameSession session;
  final int highScore;
  final int highestTileEver;
  final int comboCount;
  final int lastScoreGained;
  final int lastMergeCount;
  final bool hadBombExplosion;

  const EndlessPlaying({
    required this.session,
    required this.highScore,
    required this.highestTileEver,
    this.comboCount = 0,
    this.lastScoreGained = 0,
    this.lastMergeCount = 0,
    this.hadBombExplosion = false,
  });

  @override
  List<Object?> get props => [
        session,
        highScore,
        highestTileEver,
        comboCount,
        lastScoreGained,
        lastMergeCount,
        hadBombExplosion,
      ];
}

class EndlessGameOver extends EndlessState {
  final GameSession session;
  final int highScore;
  final int highestTileEver;
  final bool isNewRecord;

  const EndlessGameOver({
    required this.session,
    required this.highScore,
    required this.highestTileEver,
    required this.isNewRecord,
  });

  @override
  List<Object?> get props => [session, highScore, highestTileEver, isNewRecord];
}
