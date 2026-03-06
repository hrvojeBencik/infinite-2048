import 'package:equatable/equatable.dart';
import 'board.dart';

enum GameStatus { playing, won, lost, paused }

class GameSession extends Equatable {
  final Board board;
  final String? levelId;
  final GameStatus status;
  final int undosRemaining;
  final int hammersRemaining;
  final int shufflesRemaining;
  final int mergeBoostsRemaining;
  final List<Board> moveHistory;
  final Duration elapsedTime;

  const GameSession({
    required this.board,
    this.levelId,
    this.status = GameStatus.playing,
    this.undosRemaining = 3,
    this.hammersRemaining = 0,
    this.shufflesRemaining = 0,
    this.mergeBoostsRemaining = 0,
    this.moveHistory = const [],
    this.elapsedTime = Duration.zero,
  });

  GameSession copyWith({
    Board? board,
    String? levelId,
    GameStatus? status,
    int? undosRemaining,
    int? hammersRemaining,
    int? shufflesRemaining,
    int? mergeBoostsRemaining,
    List<Board>? moveHistory,
    Duration? elapsedTime,
  }) {
    return GameSession(
      board: board ?? this.board,
      levelId: levelId ?? this.levelId,
      status: status ?? this.status,
      undosRemaining: undosRemaining ?? this.undosRemaining,
      hammersRemaining: hammersRemaining ?? this.hammersRemaining,
      shufflesRemaining: shufflesRemaining ?? this.shufflesRemaining,
      mergeBoostsRemaining: mergeBoostsRemaining ?? this.mergeBoostsRemaining,
      moveHistory: moveHistory ?? this.moveHistory,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'board': board.toJson(),
        'levelId': levelId,
        'status': status.name,
        'undosRemaining': undosRemaining,
        'hammersRemaining': hammersRemaining,
        'shufflesRemaining': shufflesRemaining,
        'mergeBoostsRemaining': mergeBoostsRemaining,
        'elapsedTime': elapsedTime.inMilliseconds,
      };

  factory GameSession.fromJson(Map<String, dynamic> json) => GameSession(
        board: Board.fromJson(json['board'] as Map<String, dynamic>),
        levelId: json['levelId'] as String?,
        status: GameStatus.values.byName(json['status'] as String),
        undosRemaining: json['undosRemaining'] as int? ?? 3,
        hammersRemaining: json['hammersRemaining'] as int? ?? 0,
        shufflesRemaining: json['shufflesRemaining'] as int? ?? 0,
        mergeBoostsRemaining: json['mergeBoostsRemaining'] as int? ?? 0,
        elapsedTime: Duration(milliseconds: json['elapsedTime'] as int? ?? 0),
      );

  @override
  List<Object?> get props => [board, levelId, status, undosRemaining, elapsedTime];
}
