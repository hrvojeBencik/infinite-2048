import '../entities/achievement.dart';
import '../entities/challenge.dart';

abstract class AchievementsRepository {
  Future<List<Achievement>> getAchievements();
  Future<void> updateAchievementProgress(String achievementId, double progress);
  Future<void> unlockAchievement(String achievementId);
  Future<Challenge?> getDailyChallenge();
  Future<Challenge?> getWeeklyChallenge();
  Future<void> completeDailyChallenge(String challengeId, int score);
  Future<void> completeWeeklyChallenge(String challengeId, int score);
  Future<bool> isDailyChallengeCompleted();
  Future<int> getCompletedLevelsInZone(String zoneId);
}
