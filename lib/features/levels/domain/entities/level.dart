import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/special_tile_type.dart';

class Level extends Equatable {
  final String id;
  final String zoneId;
  final int levelNumber;
  final int boardSize;
  final int targetTileValue;
  final int? moveLimit;
  final int? timeLimitSeconds;
  final Map<SpecialTileType, double> specialTileSpawnRates;
  final List<(int, int)> blockerPositions;
  final int starThreshold2;
  final int starThreshold3;
  final bool isCompleted;
  final int bestScore;
  final int starsEarned;

  const Level({
    required this.id,
    required this.zoneId,
    required this.levelNumber,
    required this.boardSize,
    required this.targetTileValue,
    this.moveLimit,
    this.timeLimitSeconds,
    this.specialTileSpawnRates = const {},
    this.blockerPositions = const [],
    this.starThreshold2 = 1000,
    this.starThreshold3 = 2000,
    this.isCompleted = false,
    this.bestScore = 0,
    this.starsEarned = 0,
  });

  Level copyWith({
    bool? isCompleted,
    int? bestScore,
    int? starsEarned,
  }) {
    return Level(
      id: id,
      zoneId: zoneId,
      levelNumber: levelNumber,
      boardSize: boardSize,
      targetTileValue: targetTileValue,
      moveLimit: moveLimit,
      timeLimitSeconds: timeLimitSeconds,
      specialTileSpawnRates: specialTileSpawnRates,
      blockerPositions: blockerPositions,
      starThreshold2: starThreshold2,
      starThreshold3: starThreshold3,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }

  @override
  List<Object?> get props => [id, zoneId, levelNumber];
}
