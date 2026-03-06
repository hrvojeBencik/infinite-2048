import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/game_session.dart';

class GameLocalDataSource {
  Box get _box => Hive.box(AppConstants.hiveGameStateBox);

  Future<void> saveGameSession(GameSession session) async {
    await _box.put(
      session.levelId ?? 'current',
      jsonEncode(session.toJson()),
    );
  }

  Future<GameSession?> loadGameSession(String levelId) async {
    final data = _box.get(levelId);
    if (data == null) return null;
    return GameSession.fromJson(
      jsonDecode(data as String) as Map<String, dynamic>,
    );
  }

  Future<void> clearGameSession(String levelId) async {
    await _box.delete(levelId);
  }
}
