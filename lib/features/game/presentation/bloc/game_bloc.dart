import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/move_direction.dart';
import '../../domain/engine/game_engine.dart';
import '../../domain/repositories/game_repository.dart';
import '../../../levels/domain/entities/level.dart';
import '../../../progression/data/datasources/progression_local_datasource.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository repository;
  final ProgressionLocalDataSource? progressionDataSource;
  int _consecutiveMerges = 0;
  int _totalBombExplosions = 0;
  int _bestCombo = 0;
  int _totalMerges = 0;

  int get totalBombExplosions => _totalBombExplosions;
  int get bestCombo => _bestCombo;
  int get totalMerges => _totalMerges;

  GameBloc({required this.repository, this.progressionDataSource})
      : super(GameInitial()) {
    on<StartGame>(_onStartGame);
    on<ResumeGame>(_onResumeGame);
    on<SwipeMade>(_onSwipeMade);
    on<UndoMove>(_onUndoMove);
    on<UseHammer>(_onUseHammer);
    on<UseShuffle>(_onUseShuffle);
    on<UseMergeBoost>(_onUseMergeBoost);
    on<RestartLevel>(_onRestartLevel);
    on<PauseGame>(_onPauseGame);
    on<ResumeFromPause>(_onResumeFromPause);
    on<SaveAndExit>(_onSaveAndExit);
    on<GrantExtraUndo>(_onGrantExtraUndo);
    on<ContinueAfterLoss>(_onContinueAfterLoss);
  }

  void _resetSessionCounters() {
    _consecutiveMerges = 0;
    _totalBombExplosions = 0;
    _bestCombo = 0;
    _totalMerges = 0;
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    _resetSessionCounters();
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

    if (moveResult.mergeCount > 0) {
      _consecutiveMerges++;
      _totalMerges += moveResult.mergeCount;
    } else {
      _consecutiveMerges = 0;
    }
    if (_consecutiveMerges > _bestCombo) {
      _bestCombo = _consecutiveMerges;
    }
    if (moveResult.explodedTileIds.isNotEmpty) {
      _totalBombExplosions += moveResult.explodedTileIds.length;
    }

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

    final hadExplosion = moveResult.explodedTileIds.isNotEmpty;

    if (newBoard.highestTile >= currentState.level.targetTileValue) {
      final stars = _calculateStars(newBoard.score, currentState.level);
      newSession = newSession.copyWith(status: GameStatus.won);
      emit(GameWon(session: newSession, level: currentState.level, stars: stars));
      _awardXp(currentState.level, stars);
      await repository.saveLevelResult(
        levelId: currentState.level.id,
        score: newBoard.score,
        stars: stars,
      );
      await repository.clearGameSession(currentState.level.id);
      return;
    }

    if (!GameEngine.hasValidMoves(newBoard)) {
      newSession = newSession.copyWith(status: GameStatus.lost);
      emit(GameLost(session: newSession, level: currentState.level));
      await repository.clearGameSession(currentState.level.id);
      return;
    }

    if (currentState.level.moveLimit != null &&
        newBoard.moveCount >= currentState.level.moveLimit!) {
      if (newBoard.highestTile < currentState.level.targetTileValue) {
        newSession = newSession.copyWith(status: GameStatus.lost);
        emit(GameLost(session: newSession, level: currentState.level));
        await repository.clearGameSession(currentState.level.id);
        return;
      }
    }

    await repository.saveGameSession(newSession);
    emit(GamePlaying(
      session: newSession,
      level: currentState.level,
      comboCount: _consecutiveMerges,
      lastScoreGained: moveResult.scoreGained,
      hadBombExplosion: hadExplosion,
      lastMergeCount: moveResult.mergeCount,
    ));
  }

  Future<void> _onUndoMove(UndoMove event, Emitter<GameState> emit) async {
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
    await repository.saveGameSession(newSession);
  }

  Future<void> _onUseHammer(UseHammer event, Emitter<GameState> emit) async {
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
    await repository.saveGameSession(newSession);
  }

  Future<void> _onUseShuffle(UseShuffle event, Emitter<GameState> emit) async {
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
    await repository.saveGameSession(newSession);
  }

  Future<void> _onUseMergeBoost(UseMergeBoost event, Emitter<GameState> emit) async {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final session = currentState.session;
    if (session.mergeBoostsRemaining <= 0) return;

    final result = GameEngine.mergeBoost(session.board);
    if (result == null) return; // no mergeable pair found

    var newSession = session.copyWith(
      board: result.board,
      mergeBoostsRemaining: session.mergeBoostsRemaining - 1,
    );

    // Check win condition after merge
    if (result.board.highestTile >= currentState.level.targetTileValue) {
      final stars = _calculateStars(result.board.score, currentState.level);
      newSession = newSession.copyWith(status: GameStatus.won);
      emit(GameWon(session: newSession, level: currentState.level, stars: stars));
      _awardXp(currentState.level, stars);
      await repository.saveLevelResult(
        levelId: currentState.level.id,
        score: result.board.score,
        stars: stars,
      );
      await repository.clearGameSession(currentState.level.id);
      return;
    }

    emit(GamePlaying(
      session: newSession,
      level: currentState.level,
      lastScoreGained: result.scoreGained,
      lastMergeCount: 1,
    ));
  }

  Future<void> _onRestartLevel(RestartLevel event, Emitter<GameState> emit) async {
    _resetSessionCounters();
    final currentState = state;
    Level? level;
    if (currentState is GamePlaying) level = currentState.level;
    if (currentState is GameWon) level = currentState.level;
    if (currentState is GameLost) level = currentState.level;
    if (level == null) return;

    await repository.clearGameSession(level.id);

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

  Future<void> _onPauseGame(PauseGame event, Emitter<GameState> emit) async {
    final currentState = state;
    if (currentState is! GamePlaying) return;
    if (currentState.session.status != GameStatus.playing) return;
    final newSession = currentState.session.copyWith(status: GameStatus.paused);
    emit(GamePlaying(session: newSession, level: currentState.level));
    await repository.saveGameSession(
      newSession.copyWith(status: GameStatus.playing),
    );
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

  void _onGrantExtraUndo(GrantExtraUndo event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is! GamePlaying) return;
    final newSession = currentState.session.copyWith(
      undosRemaining: currentState.session.undosRemaining + 1,
    );
    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  void _onContinueAfterLoss(ContinueAfterLoss event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is! GameLost) return;

    final session = currentState.session;
    final board = session.board;

    // Remove the 3 lowest-value movable tiles to create space
    final newBoard = GameEngine.removeLowestTiles(board, count: 3);

    final newSession = session.copyWith(
      board: newBoard,
      status: GameStatus.playing,
      undosRemaining: session.undosRemaining + 1,
    );

    emit(GamePlaying(session: newSession, level: currentState.level));
  }

  void _awardXp(Level level, int stars) {
    final ds = progressionDataSource;
    if (ds == null) return;
    final baseXp = 20 + (level.boardSize * 5);
    final starBonus = stars * 10;
    ds.addXp(baseXp + starBonus);
  }

  int _calculateStars(int score, Level level) {
    if (score >= level.starThreshold3) return 3;
    if (score >= level.starThreshold2) return 2;
    return 1;
  }
}
