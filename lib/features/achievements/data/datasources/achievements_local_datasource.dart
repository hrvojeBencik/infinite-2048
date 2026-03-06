import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/challenge.dart';

class AchievementsLocalDataSource {
  Box get _box => Hive.box(AppConstants.hiveAchievementsBox);
  Box get _progressBox => Hive.box(AppConstants.hiveLevelProgressBox);

  List<Achievement> getAchievements() {
    final achievements = _defaultAchievements();
    return achievements.map((a) {
      final saved = _box.get(a.id);
      if (saved == null) return a;
      final data = jsonDecode(saved as String) as Map<String, dynamic>;
      return a.copyWith(
        progress: (data['progress'] as num?)?.toDouble() ?? 0,
        isUnlocked: data['isUnlocked'] as bool? ?? false,
        unlockedAt: data['unlockedAt'] != null
            ? DateTime.parse(data['unlockedAt'] as String)
            : null,
      );
    }).toList();
  }

  Future<void> updateProgress(String id, double progress) async {
    final existing = _box.get(id);
    Map<String, dynamic> data = {};
    if (existing != null) {
      data = jsonDecode(existing as String) as Map<String, dynamic>;
    }
    data['progress'] = progress;
    await _box.put(id, jsonEncode(data));
  }

  Future<void> unlock(String id) async {
    final existing = _box.get(id);
    Map<String, dynamic> data = {};
    if (existing != null) {
      data = jsonDecode(existing as String) as Map<String, dynamic>;
    }
    data['isUnlocked'] = true;
    data['unlockedAt'] = DateTime.now().toIso8601String();
    await _box.put(id, jsonEncode(data));
  }

  Challenge getDailyChallenge() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final boardSize = 4 + (seed % 2);
    final target = [256, 512, 1024, 2048][seed % 4];
    final hasMovelimit = seed % 3 == 0;
    final moveLimit = hasMovelimit ? 80 : null;

    final completed = isDailyChallengeCompletedSync();
    final bestScore = _getDailyChallengeBestScore();

    return Challenge(
      id: 'daily_${now.year}_${now.month}_${now.day}',
      type: ChallengeType.daily,
      title: 'Daily Challenge',
      description: 'Reach $target on a ${boardSize}x$boardSize board'
          '${hasMovelimit ? ' in $moveLimit moves' : ''}',
      boardSize: boardSize,
      targetTileValue: target,
      moveLimit: moveLimit,
      noUndos: seed % 5 == 0,
      availableFrom: DateTime(now.year, now.month, now.day),
      availableUntil: DateTime(now.year, now.month, now.day, 23, 59, 59),
      isCompleted: completed,
      bestScore: bestScore,
    );
  }

  Future<void> completeDailyChallenge(String challengeId, int score) async {
    final now = DateTime.now();
    final dateKey = _dailyChallengeKey(now);
    final existing = _box.get(dateKey);
    Map<String, dynamic> data = {};
    if (existing != null) {
      data = jsonDecode(existing as String) as Map<String, dynamic>;
    }
    final prevScore = data['bestScore'] as int? ?? 0;
    data['completed'] = true;
    data['challengeId'] = challengeId;
    data['bestScore'] = score > prevScore ? score : prevScore;
    data['completedAt'] = now.toIso8601String();
    await _box.put(dateKey, jsonEncode(data));
  }

  bool isDailyChallengeCompletedSync() {
    final dateKey = _dailyChallengeKey(DateTime.now());
    final data = _box.get(dateKey);
    if (data == null) return false;
    final map = jsonDecode(data as String) as Map<String, dynamic>;
    return map['completed'] as bool? ?? false;
  }

  int? _getDailyChallengeBestScore() {
    final dateKey = _dailyChallengeKey(DateTime.now());
    final data = _box.get(dateKey);
    if (data == null) return null;
    final map = jsonDecode(data as String) as Map<String, dynamic>;
    return map['bestScore'] as int?;
  }

  String _dailyChallengeKey(DateTime date) =>
      'daily_completed_${date.year}_${date.month}_${date.day}';

  int getCompletedLevelsInZone(String zoneId) {
    int count = 0;
    for (final key in _progressBox.keys) {
      final keyStr = key as String;
      if (!keyStr.startsWith('${zoneId}_')) continue;
      final data = _progressBox.get(key);
      if (data == null) continue;
      final map = jsonDecode(data as String) as Map<String, dynamic>;
      if (map['isCompleted'] == true) count++;
    }
    return count;
  }

  List<Achievement> _defaultAchievements() => [
        const Achievement(
          id: 'first_steps',
          title: 'First Steps',
          description: 'Complete your first level',
          category: AchievementCategory.progression,
          iconName: 'directions_walk',
          targetValue: 1,
        ),
        const Achievement(
          id: 'zone_conqueror',
          title: 'Zone Conqueror',
          description: 'Complete all levels in any zone',
          category: AchievementCategory.progression,
          iconName: 'military_tech',
          targetValue: 10,
        ),
        const Achievement(
          id: 'halfway_there',
          title: 'Halfway There',
          description: 'Complete 25 levels',
          category: AchievementCategory.progression,
          iconName: 'flag',
          targetValue: 25,
        ),
        const Achievement(
          id: 'infinite_seeker',
          title: 'Infinite Seeker',
          description: 'Complete all 50 story levels',
          category: AchievementCategory.progression,
          iconName: 'all_inclusive',
          targetValue: 50,
        ),
        const Achievement(
          id: 'perfectionist',
          title: 'Perfectionist',
          description: 'Earn 3 stars on 10 levels',
          category: AchievementCategory.skill,
          iconName: 'star',
          targetValue: 10,
        ),
        const Achievement(
          id: 'no_crutch',
          title: 'No Crutch',
          description: 'Complete 5 levels without using undo',
          category: AchievementCategory.skill,
          iconName: 'do_not_touch',
          targetValue: 5,
        ),
        const Achievement(
          id: 'tile_titan',
          title: 'Tile Titan',
          description: 'Create an 8192 tile',
          category: AchievementCategory.skill,
          iconName: 'emoji_events',
          targetValue: 1,
        ),
        const Achievement(
          id: 'demolition_expert',
          title: 'Demolition Expert',
          description: 'Trigger 50 bomb explosions',
          category: AchievementCategory.collection,
          iconName: 'local_fire_department',
          targetValue: 50,
        ),
        const Achievement(
          id: 'thaw_master',
          title: 'Thaw Master',
          description: 'Unfreeze 100 ice tiles',
          category: AchievementCategory.collection,
          iconName: 'ac_unit',
          targetValue: 100,
        ),
        const Achievement(
          id: 'daily_dedication',
          title: 'Daily Dedication',
          description: 'Play 7 days in a row',
          category: AchievementCategory.streak,
          iconName: 'calendar_today',
          targetValue: 7,
        ),
        const Achievement(
          id: 'marathon',
          title: 'Marathon',
          description: 'Complete 10 levels in one session',
          category: AchievementCategory.streak,
          iconName: 'directions_run',
          targetValue: 10,
        ),
      ];
}
