import '../entities/level.dart';
import '../entities/zone.dart';

abstract class LevelsRepository {
  Future<List<GameZone>> getZones();
  Future<List<Level>> getLevelsForZone(String zoneId);
  Future<Level?> getLevel(String levelId);
  Future<void> saveLevelProgress({
    required String levelId,
    required int score,
    required int stars,
  });
  Future<Map<String, dynamic>?> getLevelProgress(String levelId);
  Future<int> getTotalStars();
}
