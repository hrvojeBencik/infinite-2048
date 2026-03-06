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
    final template = _dailyTemplates[seed % _dailyTemplates.length];

    final completed = isDailyChallengeCompletedSync();
    final bestScore = _getDailyChallengeBestScore();

    return Challenge(
      id: 'daily_${now.year}_${now.month}_${now.day}',
      type: ChallengeType.daily,
      title: 'Daily Challenge',
      description: template.description,
      boardSize: template.boardSize,
      targetTileValue: template.target,
      moveLimit: template.moveLimit,
      timeLimitSeconds: template.timeLimitSeconds,
      noUndos: template.noUndos,
      availableFrom: DateTime(now.year, now.month, now.day),
      availableUntil: DateTime(now.year, now.month, now.day, 23, 59, 59),
      isCompleted: completed,
      bestScore: bestScore,
    );
  }

  static const _dailyTemplates = <_DailyTemplate>[
    // --- Easy 4x4 ---
    _DailyTemplate(4, 128, null, null, false, 'Reach 128 on a 4x4 board'),
    _DailyTemplate(4, 256, null, null, false, 'Reach 256 on a 4x4 board'),
    _DailyTemplate(4, 256, 60, null, false, 'Reach 256 in 60 moves'),
    _DailyTemplate(4, 512, null, null, false, 'Reach 512 on a 4x4 board'),
    _DailyTemplate(4, 256, null, null, true, 'Reach 256 with no undos'),
    _DailyTemplate(4, 128, 30, null, false, 'Speed run: 128 in 30 moves'),
    _DailyTemplate(4, 512, 80, null, false, 'Reach 512 in 80 moves'),
    _DailyTemplate(4, 256, null, 180, false, 'Reach 256 in 3 minutes'),
    _DailyTemplate(4, 512, null, null, true, 'Reach 512 with no undos'),
    _DailyTemplate(4, 1024, null, null, false, 'Reach 1024 on a 4x4 board'),

    // --- Medium 4x4 ---
    _DailyTemplate(4, 1024, 100, null, false, 'Reach 1024 in 100 moves'),
    _DailyTemplate(4, 1024, null, 300, false, 'Reach 1024 in 5 minutes'),
    _DailyTemplate(4, 1024, null, null, true, 'Reach 1024 with no undos'),
    _DailyTemplate(4, 2048, null, null, false, 'Reach 2048 on a 4x4 board'),
    _DailyTemplate(4, 2048, 200, null, false, 'Reach 2048 in 200 moves'),
    _DailyTemplate(4, 512, 50, null, true, 'Reach 512 in 50 moves, no undos'),
    _DailyTemplate(4, 128, 20, null, false, 'Tiny sprint: 128 in 20 moves'),
    _DailyTemplate(4, 256, 40, null, true, 'Reach 256 in 40 moves, no undos'),
    _DailyTemplate(4, 2048, null, 600, false, 'Reach 2048 in 10 minutes'),
    _DailyTemplate(4, 2048, null, null, true, 'Reach 2048 with no undos'),

    // --- Easy 5x5 ---
    _DailyTemplate(5, 256, null, null, false, 'Reach 256 on a 5x5 board'),
    _DailyTemplate(5, 512, null, null, false, 'Reach 512 on a 5x5 board'),
    _DailyTemplate(5, 512, 60, null, false, 'Reach 512 in 60 moves (5x5)'),
    _DailyTemplate(5, 1024, null, null, false, 'Reach 1024 on a 5x5 board'),
    _DailyTemplate(5, 1024, 80, null, false, 'Reach 1024 in 80 moves (5x5)'),
    _DailyTemplate(5, 256, null, 120, false, 'Reach 256 in 2 minutes (5x5)'),
    _DailyTemplate(5, 512, null, null, true, 'Reach 512 with no undos (5x5)'),
    _DailyTemplate(5, 2048, null, null, false, 'Reach 2048 on a 5x5 board'),
    _DailyTemplate(5, 2048, 120, null, false, 'Reach 2048 in 120 moves (5x5)'),
    _DailyTemplate(5, 1024, null, null, true, 'Reach 1024, no undos (5x5)'),

    // --- Hard 5x5 ---
    _DailyTemplate(5, 2048, null, null, true, 'Reach 2048 with no undos (5x5)'),
    _DailyTemplate(5, 4096, null, null, false, 'Reach 4096 on a 5x5 board'),
    _DailyTemplate(5, 4096, 200, null, false, 'Reach 4096 in 200 moves (5x5)'),
    _DailyTemplate(5, 2048, null, 480, false, 'Reach 2048 in 8 minutes (5x5)'),
    _DailyTemplate(5, 4096, null, null, true, 'Reach 4096 with no undos (5x5)'),

    // --- 3x3 sprints ---
    _DailyTemplate(3, 64, null, null, false, 'Reach 64 on a tiny 3x3 board'),
    _DailyTemplate(3, 128, null, null, false, 'Reach 128 on a 3x3 board'),
    _DailyTemplate(3, 64, 25, null, false, 'Reach 64 in 25 moves (3x3)'),
    _DailyTemplate(3, 128, null, 120, false, 'Reach 128 in 2 minutes (3x3)'),
    _DailyTemplate(3, 128, null, null, true, 'Reach 128, no undos (3x3)'),
    _DailyTemplate(3, 256, null, null, false, 'Reach 256 on a 3x3 board'),
    _DailyTemplate(3, 64, 15, null, true, 'Micro challenge: 64 in 15 moves'),

    // --- 6x6 endurance ---
    _DailyTemplate(6, 512, null, null, false, 'Reach 512 on a big 6x6 board'),
    _DailyTemplate(6, 1024, null, null, false, 'Reach 1024 on a 6x6 board'),
    _DailyTemplate(6, 2048, null, null, false, 'Reach 2048 on a 6x6 board'),
    _DailyTemplate(6, 1024, 100, null, false, 'Reach 1024 in 100 moves (6x6)'),
    _DailyTemplate(6, 2048, null, 600, false, 'Reach 2048 in 10 min (6x6)'),
    _DailyTemplate(6, 4096, null, null, false, 'Reach 4096 on a 6x6 board'),

    // --- Timed blitz ---
    _DailyTemplate(4, 128, null, 60, false, 'Blitz: reach 128 in 1 minute'),
    _DailyTemplate(4, 256, null, 90, true, 'Blitz: 256 in 90s, no undos'),
  ];


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

  Challenge getWeeklyChallenge() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final seed = monday.year * 10000 + monday.month * 100 + monday.day;
    final boardSize = 5 + (seed % 2);
    final target = [1024, 2048, 4096][seed % 3];
    final moveLimit = seed % 2 == 0 ? 120 : null;

    final weekKey = _weeklyChallengeKey(monday);
    final completed = _isWeeklyChallengeCompletedSync(weekKey);
    final bestScore = _getWeeklyChallengeBestScore(weekKey);

    return Challenge(
      id: 'weekly_${monday.year}_${monday.month}_${monday.day}',
      type: ChallengeType.weekly,
      title: 'Weekly Challenge',
      description: 'Reach $target on a ${boardSize}x$boardSize board'
          '${moveLimit != null ? ' in $moveLimit moves' : ''}',
      boardSize: boardSize,
      targetTileValue: target,
      moveLimit: moveLimit,
      noUndos: seed % 7 == 0,
      availableFrom: DateTime(monday.year, monday.month, monday.day),
      availableUntil: sunday,
      isCompleted: completed,
      bestScore: bestScore,
    );
  }

  Future<void> completeWeeklyChallenge(String challengeId, int score) async {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final weekKey = _weeklyChallengeKey(monday);

    final existing = _box.get(weekKey);
    Map<String, dynamic> data = {};
    if (existing != null) {
      data = jsonDecode(existing as String) as Map<String, dynamic>;
    }
    final prevScore = data['bestScore'] as int? ?? 0;
    data['completed'] = true;
    data['challengeId'] = challengeId;
    data['bestScore'] = score > prevScore ? score : prevScore;
    data['completedAt'] = now.toIso8601String();
    await _box.put(weekKey, jsonEncode(data));
  }

  bool _isWeeklyChallengeCompletedSync(String weekKey) {
    final data = _box.get(weekKey);
    if (data == null) return false;
    final map = jsonDecode(data as String) as Map<String, dynamic>;
    return map['completed'] as bool? ?? false;
  }

  int? _getWeeklyChallengeBestScore(String weekKey) {
    final data = _box.get(weekKey);
    if (data == null) return null;
    final map = jsonDecode(data as String) as Map<String, dynamic>;
    return map['bestScore'] as int?;
  }

  String _weeklyChallengeKey(DateTime monday) =>
      'weekly_completed_${monday.year}_${monday.month}_${monday.day}';

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

  // Keep in sync with router: the challenge route reads boardSize/target/etc
  // from the Challenge entity, so adding new fields here just works.

  List<Achievement> _defaultAchievements() => [
        // --- PROGRESSION (10) ---
        const Achievement(
          id: 'first_steps',
          title: 'First Steps',
          description: 'Complete your first level',
          category: AchievementCategory.progression,
          iconName: 'directions_walk',
          targetValue: 1,
        ),
        const Achievement(
          id: 'getting_warmed_up',
          title: 'Getting Warmed Up',
          description: 'Complete 5 levels',
          category: AchievementCategory.progression,
          iconName: 'whatshot',
          targetValue: 5,
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
          id: 'zone_hopper',
          title: 'Zone Hopper',
          description: 'Play a level in 3 different zones',
          category: AchievementCategory.progression,
          iconName: 'explore',
          targetValue: 3,
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
          id: 'daily_warrior',
          title: 'Daily Warrior',
          description: 'Complete 10 daily challenges',
          category: AchievementCategory.progression,
          iconName: 'today',
          targetValue: 10,
        ),
        const Achievement(
          id: 'weekly_champion',
          title: 'Weekly Champion',
          description: 'Complete 5 weekly challenges',
          category: AchievementCategory.progression,
          iconName: 'date_range',
          targetValue: 5,
        ),
        const Achievement(
          id: 'endless_explorer',
          title: 'Endless Explorer',
          description: 'Play 10 endless mode games',
          category: AchievementCategory.progression,
          iconName: 'all_inclusive',
          targetValue: 10,
        ),
        const Achievement(
          id: 'level_10',
          title: 'Rising Star',
          description: 'Reach player level 10',
          category: AchievementCategory.progression,
          iconName: 'trending_up',
          targetValue: 10,
        ),

        // --- SKILL (10) ---
        const Achievement(
          id: 'perfectionist',
          title: 'Perfectionist',
          description: 'Earn 3 stars on 10 levels',
          category: AchievementCategory.skill,
          iconName: 'star',
          targetValue: 10,
        ),
        const Achievement(
          id: 'flawless',
          title: 'Flawless',
          description: 'Earn 3 stars on 25 levels',
          category: AchievementCategory.skill,
          iconName: 'stars',
          targetValue: 25,
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
          id: 'speed_demon',
          title: 'Speed Demon',
          description: 'Complete a level in under 30 moves',
          category: AchievementCategory.skill,
          iconName: 'speed',
          targetValue: 1,
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
          id: 'merge_master',
          title: 'Merge Master',
          description: 'Achieve a 5x combo streak',
          category: AchievementCategory.skill,
          iconName: 'bolt',
          targetValue: 1,
        ),
        const Achievement(
          id: 'score_legend',
          title: 'Score Legend',
          description: 'Score over 50,000 in a single level',
          category: AchievementCategory.skill,
          iconName: 'leaderboard',
          targetValue: 1,
        ),
        const Achievement(
          id: 'endless_survivor',
          title: 'Endless Survivor',
          description: 'Score over 10,000 in endless mode',
          category: AchievementCategory.skill,
          iconName: 'shield',
          targetValue: 1,
        ),
        const Achievement(
          id: 'endless_legend',
          title: 'Endless Legend',
          description: 'Score over 50,000 in endless mode',
          category: AchievementCategory.skill,
          iconName: 'workspace_premium',
          targetValue: 1,
        ),
        const Achievement(
          id: 'no_mercy',
          title: 'No Mercy',
          description: 'Complete a level with 0 undos remaining',
          category: AchievementCategory.skill,
          iconName: 'gavel',
          targetValue: 1,
        ),

        // --- COLLECTION (5) ---
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
          id: 'wildcard_wizard',
          title: 'Wildcard Wizard',
          description: 'Merge 30 wildcard tiles',
          category: AchievementCategory.collection,
          iconName: 'auto_awesome',
          targetValue: 30,
        ),
        const Achievement(
          id: 'multiplier_mania',
          title: 'Multiplier Mania',
          description: 'Use 25 multiplier tiles',
          category: AchievementCategory.collection,
          iconName: 'close',
          targetValue: 25,
        ),
        const Achievement(
          id: 'total_merges_1k',
          title: 'Merger Extraordinaire',
          description: 'Perform 1,000 total merges',
          category: AchievementCategory.collection,
          iconName: 'merge_type',
          targetValue: 1000,
        ),

        // --- STREAK (5) ---
        const Achievement(
          id: 'daily_dedication',
          title: 'Daily Dedication',
          description: 'Play 7 days in a row',
          category: AchievementCategory.streak,
          iconName: 'calendar_today',
          targetValue: 7,
        ),
        const Achievement(
          id: 'fortnight_fury',
          title: 'Fortnight Fury',
          description: 'Play 14 days in a row',
          category: AchievementCategory.streak,
          iconName: 'event_repeat',
          targetValue: 14,
        ),
        const Achievement(
          id: 'monthly_master',
          title: 'Monthly Master',
          description: 'Play 30 days in a row',
          category: AchievementCategory.streak,
          iconName: 'military_tech',
          targetValue: 30,
        ),
        const Achievement(
          id: 'marathon',
          title: 'Marathon',
          description: 'Complete 10 levels in one session',
          category: AchievementCategory.streak,
          iconName: 'directions_run',
          targetValue: 10,
        ),
        const Achievement(
          id: 'thousand_moves',
          title: 'Thousand Moves',
          description: 'Make 1,000 total moves across all games',
          category: AchievementCategory.streak,
          iconName: 'swap_horiz',
          targetValue: 1000,
        ),
      ];
}

class _DailyTemplate {
  final int boardSize;
  final int target;
  final int? moveLimit;
  final int? timeLimitSeconds;
  final bool noUndos;
  final String description;

  const _DailyTemplate(
    this.boardSize,
    this.target,
    this.moveLimit,
    this.timeLimitSeconds,
    this.noUndos,
    this.description,
  );
}
