import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../game/domain/entities/game_session.dart';

class EndlessLocalDataSource {
  static const _sessionKey = 'endless_session';
  static const _highScoreKey = 'endless_high_score';
  static const _highestTileKey = 'endless_highest_tile';
  static const _gamesPlayedKey = 'endless_games_played';

  Box get _box => Hive.box(AppConstants.hiveGameStateBox);

  Future<void> saveSession(GameSession session) async {
    await _box.put(_sessionKey, jsonEncode(session.toJson()));
  }

  GameSession? loadSession() {
    final data = _box.get(_sessionKey);
    if (data == null) return null;
    try {
      return GameSession.fromJson(
        jsonDecode(data as String) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('Failed to load endless session: $e');
      return null;
    }
  }

  Future<void> clearSession() async {
    await _box.delete(_sessionKey);
  }

  int getHighScore() => _box.get(_highScoreKey, defaultValue: 0) as int;

  int getHighestTile() => _box.get(_highestTileKey, defaultValue: 0) as int;

  int getGamesPlayed() => _box.get(_gamesPlayedKey, defaultValue: 0) as int;

  Future<void> recordGameOver({
    required int score,
    required int highestTile,
  }) async {
    final prevHigh = getHighScore();
    if (score > prevHigh) {
      await _box.put(_highScoreKey, score);
    }
    final prevTile = getHighestTile();
    if (highestTile > prevTile) {
      await _box.put(_highestTileKey, highestTile);
    }
    await _box.put(_gamesPlayedKey, getGamesPlayed() + 1);
    await clearSession();
  }

  Future<void> resetAll() async {
    await _box.delete(_sessionKey);
    await _box.delete(_highScoreKey);
    await _box.delete(_highestTileKey);
    await _box.delete(_gamesPlayedKey);
  }
}
