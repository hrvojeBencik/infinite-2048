import '../entities/achievement.dart';
import '../entities/challenge.dart';

abstract class AchievementsRepository {
  Future<List<Achievement>> getAchievements();
  Future<void> updateAchievementProgress(String achievementId, double progress);
  Future<void> unlockAchievement(String achievementId);
  Future<Challenge?> getDailyChallenge();
  Future<List<Challenge>> getWeeklyChallenges();
  Future<void> completeDailyChallenge(String challengeId, int score);
}
