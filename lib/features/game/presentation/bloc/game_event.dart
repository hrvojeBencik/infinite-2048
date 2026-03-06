part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartGame extends GameEvent {
  final Level level;
  final int undosAvailable;
  final int hammersAvailable;
  final int shufflesAvailable;
  final int mergeBoostsAvailable;

  const StartGame({
    required this.level,
    this.undosAvailable = 3,
    this.hammersAvailable = 0,
    this.shufflesAvailable = 0,
    this.mergeBoostsAvailable = 0,
  });

  @override
  List<Object?> get props => [level];
}

class ResumeGame extends GameEvent {
  final String levelId;
  final Level level;

  const ResumeGame({required this.levelId, required this.level});

  @override
  List<Object?> get props => [levelId];
}

class SwipeMade extends GameEvent {
  final MoveDirection direction;

  const SwipeMade(this.direction);

  @override
  List<Object?> get props => [direction];
}

class UndoMove extends GameEvent {
  const UndoMove();
}

class UseHammer extends GameEvent {
  final String tileId;

  const UseHammer(this.tileId);

  @override
  List<Object?> get props => [tileId];
}

class UseShuffle extends GameEvent {
  const UseShuffle();
}

class RestartLevel extends GameEvent {
  final int undosAvailable;
  final int hammersAvailable;
  final int shufflesAvailable;
  final int mergeBoostsAvailable;

  const RestartLevel({
    this.undosAvailable = 3,
    this.hammersAvailable = 0,
    this.shufflesAvailable = 0,
    this.mergeBoostsAvailable = 0,
  });
}

class PauseGame extends GameEvent {
  const PauseGame();
}

class ResumeFromPause extends GameEvent {
  const ResumeFromPause();
}

class SaveAndExit extends GameEvent {
  const SaveAndExit();
}

class GrantExtraUndo extends GameEvent {
  const GrantExtraUndo();
}
