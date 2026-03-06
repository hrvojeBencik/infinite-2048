import '../entities/game_session.dart';

abstract class GameRepository {
  Future<void> saveGameSession(GameSession session);
  Future<GameSession?> loadGameSession(String levelId);
  Future<void> clearGameSession(String levelId);
  Future<void> saveLevelResult({
    required String levelId,
    required int score,
    required int stars,
  });
}
