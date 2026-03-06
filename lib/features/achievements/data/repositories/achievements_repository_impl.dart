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
  Future<List<Challenge>> getWeeklyChallenges() async {
    // Simplified: return a list based on current week
    return [];
  }

  @override
  Future<void> completeDailyChallenge(String challengeId, int score) async {
    // Mark challenge as completed locally
  }
}
