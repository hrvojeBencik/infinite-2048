import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';

class GameStats {
  final int totalGamesPlayed;
  final int levelsCompleted;
  final int totalScore;
  final int highestTileEver;
  final int totalMerges;
  final int bombsTriggered;
  final int bestComboStreak;
  final int totalMoves;
  final int threeStarLevels;
  final int totalUndosUsed;

  const GameStats({
    this.totalGamesPlayed = 0,
    this.levelsCompleted = 0,
    this.totalScore = 0,
    this.highestTileEver = 0,
    this.totalMerges = 0,
    this.bombsTriggered = 0,
    this.bestComboStreak = 0,
    this.totalMoves = 0,
    this.threeStarLevels = 0,
    this.totalUndosUsed = 0,
  });

  GameStats copyWith({
    int? totalGamesPlayed,
    int? levelsCompleted,
    int? totalScore,
    int? highestTileEver,
    int? totalMerges,
    int? bombsTriggered,
    int? bestComboStreak,
    int? totalMoves,
    int? threeStarLevels,
    int? totalUndosUsed,
  }) {
    return GameStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalScore: totalScore ?? this.totalScore,
      highestTileEver: highestTileEver ?? this.highestTileEver,
      totalMerges: totalMerges ?? this.totalMerges,
      bombsTriggered: bombsTriggered ?? this.bombsTriggered,
      bestComboStreak: bestComboStreak ?? this.bestComboStreak,
      totalMoves: totalMoves ?? this.totalMoves,
      threeStarLevels: threeStarLevels ?? this.threeStarLevels,
      totalUndosUsed: totalUndosUsed ?? this.totalUndosUsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'levelsCompleted': levelsCompleted,
        'totalScore': totalScore,
        'highestTileEver': highestTileEver,
        'totalMerges': totalMerges,
        'bombsTriggered': bombsTriggered,
        'bestComboStreak': bestComboStreak,
        'totalMoves': totalMoves,
        'threeStarLevels': threeStarLevels,
        'totalUndosUsed': totalUndosUsed,
      };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalGamesPlayed: (json['totalGamesPlayed'] as num?)?.toInt() ?? 0,
      levelsCompleted: (json['levelsCompleted'] as num?)?.toInt() ?? 0,
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      highestTileEver: (json['highestTileEver'] as num?)?.toInt() ?? 0,
      totalMerges: (json['totalMerges'] as num?)?.toInt() ?? 0,
      bombsTriggered: (json['bombsTriggered'] as num?)?.toInt() ?? 0,
      bestComboStreak: (json['bestComboStreak'] as num?)?.toInt() ?? 0,
      totalMoves: (json['totalMoves'] as num?)?.toInt() ?? 0,
      threeStarLevels: (json['threeStarLevels'] as num?)?.toInt() ?? 0,
      totalUndosUsed: (json['totalUndosUsed'] as num?)?.toInt() ?? 0,
    );
  }
}

class StatisticsLocalDataSource {
  Box get _box => Hive.box(AppConstants.hiveSettingsBox);

  static const String _statsKey = 'game_stats';

  GameStats getStats() {
    final data = _box.get(_statsKey);
    if (data == null) return const GameStats();

    try {
      final map = jsonDecode(data as String) as Map<String, dynamic>;
      return GameStats.fromJson(map);
    } catch (_) {
      return const GameStats();
    }
  }

  Future<void> saveStats(GameStats stats) async {
    await _box.put(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<void> recordGamePlayed() async {
    final stats = getStats();
    await saveStats(stats.copyWith(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
    ));
  }

  Future<void> recordLevelCompleted({
    required int score,
    required int stars,
    required int highestTile,
    required int merges,
    required int moves,
    required int undosUsed,
    required int bombExplosions,
    required int bestCombo,
  }) async {
    final stats = getStats();
    final newHighestTile = highestTile > stats.highestTileEver
        ? highestTile
        : stats.highestTileEver;
    final newBestCombo =
        bestCombo > stats.bestComboStreak ? bestCombo : stats.bestComboStreak;

    await saveStats(stats.copyWith(
      levelsCompleted: stats.levelsCompleted + 1,
      totalScore: stats.totalScore + score,
      highestTileEver: newHighestTile,
      totalMerges: stats.totalMerges + merges,
      totalMoves: stats.totalMoves + moves,
      totalUndosUsed: stats.totalUndosUsed + undosUsed,
      bombsTriggered: stats.bombsTriggered + bombExplosions,
      bestComboStreak: newBestCombo,
      threeStarLevels:
          stars >= 3 ? stats.threeStarLevels + 1 : stats.threeStarLevels,
    ));
  }

  Future<void> recordMove({
    required int mergeCount,
    required bool hadBombExplosion,
    required int comboCount,
  }) async {
    final stats = getStats();
    final newBestCombo =
        comboCount > stats.bestComboStreak ? comboCount : stats.bestComboStreak;

    await saveStats(stats.copyWith(
      totalMoves: stats.totalMoves + 1,
      totalMerges: stats.totalMerges + mergeCount,
      bombsTriggered: hadBombExplosion
          ? stats.bombsTriggered + 1
          : stats.bombsTriggered,
      bestComboStreak: newBestCombo,
    ));
  }

  Future<void> resetStats() async {
    await saveStats(const GameStats());
  }
}
