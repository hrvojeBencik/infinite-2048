import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/game_session.dart';
import '../../../game/domain/entities/move_direction.dart';
import '../../../game/domain/engine/game_engine.dart';
import '../../data/datasources/endless_local_datasource.dart';

part 'endless_event.dart';
part 'endless_state.dart';

class EndlessBloc extends Bloc<EndlessEvent, EndlessState> {
  final EndlessLocalDataSource dataSource;
  int _consecutiveMerges = 0;

  EndlessBloc({required this.dataSource}) : super(EndlessInitial()) {
    on<StartEndless>(_onStart);
    on<EndlessSwipe>(_onSwipe);
    on<EndlessUndo>(_onUndo);
    on<EndlessPause>(_onPause);
    on<EndlessResume>(_onResume);
    on<EndlessSaveAndExit>(_onSaveAndExit);
    on<EndlessRestart>(_onRestart);
  }

  Future<void> _onStart(StartEndless event, Emitter<EndlessState> emit) async {
    final saved = dataSource.loadSession();
    final highScore = dataSource.getHighScore();
    final highestTileEver = dataSource.getHighestTile();

    if (saved != null && saved.status == GameStatus.playing) {
      emit(EndlessPlaying(
        session: saved,
        highScore: highScore,
        highestTileEver: highestTileEver,
      ));
      return;
    }

    final board = GameEngine.createBoard(4);
    final session = GameSession(
      board: board,
      levelId: 'endless',
      undosRemaining: event.undosAvailable,
    );

    emit(EndlessPlaying(
      session: session,
      highScore: highScore,
      highestTileEver: highestTileEver,
    ));
  }

  Future<void> _onSwipe(EndlessSwipe event, Emitter<EndlessState> emit) async {
    final currentState = state;
    if (currentState is! EndlessPlaying) return;
    if (currentState.session.status != GameStatus.playing) return;

    final session = currentState.session;
    final moveResult = GameEngine.moveTiles(session.board, event.direction);
    if (!moveResult.boardChanged) return;

    if (moveResult.mergeCount > 0) {
      _consecutiveMerges++;
    } else {
      _consecutiveMerges = 0;
    }

    final newBoard = GameEngine.spawnTile(moveResult.board);

    final history = [...session.moveHistory, session.board];
    final maxHistory = 20;
    final trimmedHistory = history.length > maxHistory
        ? history.sublist(history.length - maxHistory)
        : history;

    final newSession = session.copyWith(
      board: newBoard,
      moveHistory: trimmedHistory,
    );

    if (!GameEngine.hasValidMoves(newBoard)) {
      final isNewRecord = newBoard.score > currentState.highScore;
      await dataSource.recordGameOver(
        score: newBoard.score,
        highestTile: newBoard.highestTile,
      );
      emit(EndlessGameOver(
        session: newSession.copyWith(status: GameStatus.lost),
        highScore: isNewRecord ? newBoard.score : currentState.highScore,
        highestTileEver: newBoard.highestTile > currentState.highestTileEver
            ? newBoard.highestTile
            : currentState.highestTileEver,
        isNewRecord: isNewRecord,
      ));
      return;
    }

    await dataSource.saveSession(newSession);
    emit(EndlessPlaying(
      session: newSession,
      highScore: currentState.highScore,
      highestTileEver: newBoard.highestTile > currentState.highestTileEver
          ? newBoard.highestTile
          : currentState.highestTileEver,
      comboCount: _consecutiveMerges,
      lastScoreGained: moveResult.scoreGained,
      lastMergeCount: moveResult.mergeCount,
      hadBombExplosion: moveResult.explodedTileIds.isNotEmpty,
    ));
  }

  void _onUndo(EndlessUndo event, Emitter<EndlessState> emit) {
    final currentState = state;
    if (currentState is! EndlessPlaying) return;

    final session = currentState.session;
    if (session.moveHistory.isEmpty || session.undosRemaining <= 0) return;

    final previousBoard = session.moveHistory.last;
    final newHistory =
        session.moveHistory.sublist(0, session.moveHistory.length - 1);

    final newSession = session.copyWith(
      board: previousBoard,
      undosRemaining: session.undosRemaining - 1,
      moveHistory: newHistory,
    );

    emit(EndlessPlaying(
      session: newSession,
      highScore: currentState.highScore,
      highestTileEver: currentState.highestTileEver,
    ));
  }

  void _onPause(EndlessPause event, Emitter<EndlessState> emit) {
    final currentState = state;
    if (currentState is! EndlessPlaying) return;
    if (currentState.session.status != GameStatus.playing) return;

    emit(EndlessPlaying(
      session: currentState.session.copyWith(status: GameStatus.paused),
      highScore: currentState.highScore,
      highestTileEver: currentState.highestTileEver,
    ));
  }

  void _onResume(EndlessResume event, Emitter<EndlessState> emit) {
    final currentState = state;
    if (currentState is! EndlessPlaying) return;
    if (currentState.session.status != GameStatus.paused) return;

    emit(EndlessPlaying(
      session: currentState.session.copyWith(status: GameStatus.playing),
      highScore: currentState.highScore,
      highestTileEver: currentState.highestTileEver,
    ));
  }

  Future<void> _onSaveAndExit(
      EndlessSaveAndExit event, Emitter<EndlessState> emit) async {
    final currentState = state;
    if (currentState is! EndlessPlaying) return;

    final session = currentState.session;
    if (session.status == GameStatus.playing ||
        session.status == GameStatus.paused) {
      await dataSource
          .saveSession(session.copyWith(status: GameStatus.playing));
    }
  }

  Future<void> _onRestart(
      EndlessRestart event, Emitter<EndlessState> emit) async {
    await dataSource.clearSession();
    _consecutiveMerges = 0;

    final board = GameEngine.createBoard(4);
    final session = GameSession(
      board: board,
      levelId: 'endless',
      undosRemaining: event.undosAvailable,
    );

    emit(EndlessPlaying(
      session: session,
      highScore: dataSource.getHighScore(),
      highestTileEver: dataSource.getHighestTile(),
    ));
  }
}
