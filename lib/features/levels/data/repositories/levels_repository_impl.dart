import '../../domain/entities/level.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/levels_repository.dart';
import '../datasources/levels_local_datasource.dart';

class LevelsRepositoryImpl implements LevelsRepository {
  final LevelsLocalDataSource localDataSource;

  LevelsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<GameZone>> getZones() async {
    final zones = localDataSource.getZones();
    final totalStars = localDataSource.getTotalStars();

    return zones.map((zone) {
      final levels = localDataSource.getLevelsForZone(zone.id);
      final isLocked = totalStars < zone.requiredStarsToUnlock;
      return zone.copyWith(levels: levels, isLocked: isLocked);
    }).toList();
  }

  @override
  Future<List<Level>> getLevelsForZone(String zoneId) async {
    return localDataSource.getLevelsForZone(zoneId);
  }

  @override
  Future<Level?> getLevel(String levelId) async {
    return localDataSource.getLevel(levelId);
  }

  @override
  Future<void> saveLevelProgress({
    required String levelId,
    required int score,
    required int stars,
  }) async {
    await localDataSource.saveLevelProgress(
      levelId: levelId,
      score: score,
      stars: stars,
    );
  }

  @override
  Future<Map<String, dynamic>?> getLevelProgress(String levelId) async {
    return localDataSource.getLevelProgress(levelId);
  }

  @override
  Future<int> getTotalStars() async {
    return localDataSource.getTotalStars();
  }
}
