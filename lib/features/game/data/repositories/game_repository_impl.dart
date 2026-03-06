import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource localDataSource;

  GameRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveGameSession(GameSession session) async {
    await localDataSource.saveGameSession(session);
  }

  @override
  Future<GameSession?> loadGameSession(String levelId) async {
    return localDataSource.loadGameSession(levelId);
  }

  @override
  Future<void> clearGameSession(String levelId) async {
    await localDataSource.clearGameSession(levelId);
  }

  @override
  Future<void> saveLevelResult({
    required String levelId,
    required int score,
    required int stars,
  }) async {
    final box = Hive.box(AppConstants.hiveLevelProgressBox);
    final existing = box.get(levelId);
    Map<String, dynamic> data = {};
    if (existing != null) {
      data = jsonDecode(existing as String) as Map<String, dynamic>;
    }

    final prevScore = data['bestScore'] as int? ?? 0;
    final prevStars = data['starsEarned'] as int? ?? 0;

    data['levelId'] = levelId;
    data['isCompleted'] = true;
    data['bestScore'] = score > prevScore ? score : prevScore;
    data['starsEarned'] = stars > prevStars ? stars : prevStars;

    await box.put(levelId, jsonEncode(data));
  }
}
