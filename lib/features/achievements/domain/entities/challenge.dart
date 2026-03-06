import 'package:equatable/equatable.dart';

enum ChallengeType { daily, weekly }

class Challenge extends Equatable {
  final String id;
  final ChallengeType type;
  final String title;
  final String description;
  final int boardSize;
  final int targetTileValue;
  final int? moveLimit;
  final int? timeLimitSeconds;
  final bool noUndos;
  final DateTime availableFrom;
  final DateTime availableUntil;
  final bool isCompleted;
  final int? bestScore;

  const Challenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.boardSize,
    required this.targetTileValue,
    this.moveLimit,
    this.timeLimitSeconds,
    this.noUndos = false,
    required this.availableFrom,
    required this.availableUntil,
    this.isCompleted = false,
    this.bestScore,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(availableFrom) && now.isBefore(availableUntil);
  }

  @override
  List<Object?> get props => [id, type, isCompleted];
}
