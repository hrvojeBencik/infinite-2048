import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/move_direction.dart';
import '../../domain/engine/game_engine.dart';
import '../../domain/repositories/game_repository.dart';
import '../../../levels/domain/entities/level.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository repository;

  GameBloc({required this.repository}) : super(GameInitial()) {
    on<StartGame>(_onStartGame);
    on<ResumeGame>(_onResumeGame);
    on<SwipeMade>(_onSwipeMade);
    on<UndoMove>(_onUndoMove);
    on<UseHammer>(_onUseHammer);
    on<UseShuffle>(_onUseShuffle);
    on<RestartLevel>(_onRestartLevel);
    on<PauseGame>(_onPauseGame);
    on<ResumeFromPause>(_onResumeFromPause);
    on<SaveAndExit>(_onSaveAndExit);
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    final saved = await repository.loadGameSession(event.level.id);
    if (saved != null && saved.status == GameStatus.playing) {
      emit(GamePlaying(session: saved, level: event.level));
      return;
    }

    final board = GameEngine.createBoard(
      event.level.boardSize,
      blockers: event.level.blockerPositions,
    );

    final session = GameSession(
      board: board,
      levelId: event.level.id,
      undosRemaining: event.undosAvailable,
      hammersRemaining: event.hammersAvailable,
      shufflesRemaining: event.shufflesAvailable,
      mergeBoostsRemaining: event.mergeBoostsAvailable,
    );

    emit(GamePlaying(session: session, level: event.level));
  }

  Future<void> _onResumeGame(ResumeGame event, Emitter<GameState> emit) async {
    final session = await repository.loadGameSession(event.levelId);
    if (session != null) {
      emit(GamePlaying(session: session, level: event.level));
    }
  }

  Future<void> _onSwipeMade(SwipeMade event, Emitter<GameState> emit) async {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final session = currentState.session;
    if (session.status != GameStatus.playing) return;

    final moveResult = GameEngine.moveTiles(session.board, event.direction);
    if (!moveResult.boardChanged) return;

    var newBoard = GameEngine.spawnTile(
      moveResult.board,
      spawnRates: currentState.level.specialTileSpawnRates,
    );

    final history = [...session.moveHistory, session.board];
    final maxHistory = 20;
    final trimmedHistory =
        history.length > maxHistory ? history.sublist(history.length - maxHistory) : history;

    var newSession = session.copyWith(
      board: newBoard,
      moveHistory: trimmedHistory,
    );

    if (newBoard.highestTile >= currentState.level.targetTileValue) {
      final stars = _calculateStars(newBoard.score, currentState.level);
      newSession = newSession.copyWith(status: GameStatus.won);
      await repository.saveLevelResult(
        levelId: currentState.level.id,
        score: newBoard.score,
        stars: stars,
      );
      await repository.clearGameSession(currentState.level.id);
      emit(GameWon(session: newSession, level: currentState.level, stars: stars));
      return;
    }

    if (!GameEngine.hasValidMoves(newBoard)) {
      newSession = newSession.copyWith(status: GameStatus.lost);
      await repository.clearGameSession(currentState.level.id);
      emit(GameLost(session: newSession, level: currentState.level));
      return;
    }

    if (currentState.level.moveLimit != null &&
        newBoard.moveCount >= currentState.level.moveLimit!) {
      if (newBoard.highestTile < currentState.level.targetTileValue) {
        newSession = newSession.copyWith(status: GameStatus.lost);
        await repository.clearGameSession(currentState.level.id);
        emit(GameLost(session: newSession, level: currentState.level));
        return;
      }
    }

    await repository.saveGameSession(newSession);
    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  void _onUndoMove(UndoMove event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final session = currentState.session;
    if (session.moveHistory.isEmpty || session.undosRemaining <= 0) return;

    final previousBoard = session.moveHistory.last;
    final newHistory = session.moveHistory.sublist(0, session.moveHistory.length - 1);

    final newSession = session.copyWith(
      board: previousBoard,
      undosRemaining: session.undosRemaining - 1,
      moveHistory: newHistory,
    );

    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  void _onUseHammer(UseHammer event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final session = currentState.session;
    if (session.hammersRemaining <= 0) return;

    final newBoard = GameEngine.removeTile(session.board, event.tileId);
    final newSession = session.copyWith(
      board: newBoard,
      hammersRemaining: session.hammersRemaining - 1,
    );

    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  void _onUseShuffle(UseShuffle event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final session = currentState.session;
    if (session.shufflesRemaining <= 0) return;

    final newBoard = GameEngine.shuffleBoard(session.board);
    final newSession = session.copyWith(
      board: newBoard,
      shufflesRemaining: session.shufflesRemaining - 1,
    );

    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  void _onRestartLevel(RestartLevel event, Emitter<GameState> emit) {
    final currentState = state;
    Level? level;
    if (currentState is GamePlaying) level = currentState.level;
    if (currentState is GameWon) level = currentState.level;
    if (currentState is GameLost) level = currentState.level;
    if (level == null) return;

    repository.clearGameSession(level.id);

    final board = GameEngine.createBoard(
      level.boardSize,
      blockers: level.blockerPositions,
    );

    final session = GameSession(
      board: board,
      levelId: level.id,
      undosRemaining: event.undosAvailable,
      hammersRemaining: event.hammersAvailable,
      shufflesRemaining: event.shufflesAvailable,
      mergeBoostsRemaining: event.mergeBoostsAvailable,
    );

    emit(GamePlaying(session: session, level: level));
  }

  void _onPauseGame(PauseGame event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is! GamePlaying) return;
    if (currentState.session.status != GameStatus.playing) return;
    final newSession = currentState.session.copyWith(status: GameStatus.paused);
    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  void _onResumeFromPause(ResumeFromPause event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is! GamePlaying) return;
    if (currentState.session.status != GameStatus.paused) return;
    final newSession = currentState.session.copyWith(status: GameStatus.playing);
    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  Future<void> _onSaveAndExit(SaveAndExit event, Emitter<GameState> emit) async {
    final currentState = state;
    if (currentState is! GamePlaying) return;
    if (currentState.session.status == GameStatus.playing ||
        currentState.session.status == GameStatus.paused) {
      final sessionToSave = currentState.session.copyWith(status: GameStatus.playing);
      await repository.saveGameSession(sessionToSave);
    }
  }

  int _calculateStars(int score, Level level) {
    if (score >= level.starThreshold3) return 3;
    if (score >= level.starThreshold2) return 2;
    return 1;
  }
}
