import '../../domain/entities/achievement.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/repositories/achievements_repository.dart';
import '../datasources/achievements_local_datasource.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  final AchievementsLocalDataSource localDataSource;

  AchievementsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Achievement>> getAchievements() async {
    return localDataSource.getAchievements();
  }

  @override
  Future<void> updateAchievementProgress(
      String achievementId, double progress) async {
    await localDataSource.updateProgress(achievementId, progress);
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    await localDataSource.unlock(achievementId);
  }

  @override
  Future<Challenge?> getDailyChallenge() async {
    return localDataSource.getDailyChallenge();
  }

  @override
  Future<Challenge?> getWeeklyChallenge() async {
    return localDataSource.getWeeklyChallenge();
  }

  @override
  Future<void> completeDailyChallenge(String challengeId, int score) async {
    await localDataSource.completeDailyChallenge(challengeId, score);
  }

  @override
  Future<void> completeWeeklyChallenge(String challengeId, int score) async {
    await localDataSource.completeWeeklyChallenge(challengeId, score);
  }

  @override
  Future<bool> isDailyChallengeCompleted() async {
    return localDataSource.isDailyChallengeCompletedSync();
  }

  @override
  Future<int> getCompletedLevelsInZone(String zoneId) async {
    return localDataSource.getCompletedLevelsInZone(zoneId);
  }
}
