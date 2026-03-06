import 'package:equatable/equatable.dart';

class PlayerProfile extends Equatable {
  final int totalXp;
  final int level;
  final int xpForCurrentLevel;
  final int xpRequiredForNextLevel;
  final String activeTileThemeId;
  final List<String> unlockedTileThemeIds;
  final int loginStreak;
  final DateTime? lastLoginDate;

  const PlayerProfile({
    required this.totalXp,
    required this.level,
    required this.xpForCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.activeTileThemeId,
    required this.unlockedTileThemeIds,
    required this.loginStreak,
    this.lastLoginDate,
  });

  /// Total XP needed to reach [level].
  /// Level 1 = 0 XP, level 2 = 100 XP, level 3 = 250 XP, etc.
  /// Formula: 25 * level * level + 25 * level - 50 (for level >= 2)
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    return 25 * level * level + 25 * level - 50;
  }

  /// Computes player level from total XP.
  static int levelFromXp(int totalXp) {
    if (totalXp < 0) return 1;
    int level = 1;
    while (xpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  factory PlayerProfile.fromTotalXp({
    required int totalXp,
    required String activeTileThemeId,
    required List<String> unlockedTileThemeIds,
    required int loginStreak,
    DateTime? lastLoginDate,
  }) {
    final level = levelFromXp(totalXp);
    final xpForCurrent = totalXp - xpForLevel(level);
    final xpRequired = xpForLevel(level + 1) - xpForLevel(level);

    return PlayerProfile(
      totalXp: totalXp,
      level: level,
      xpForCurrentLevel: xpForCurrent,
      xpRequiredForNextLevel: xpRequired,
      activeTileThemeId: activeTileThemeId,
      unlockedTileThemeIds: unlockedTileThemeIds,
      loginStreak: loginStreak,
      lastLoginDate: lastLoginDate,
    );
  }

  PlayerProfile copyWith({
    int? totalXp,
    int? level,
    int? xpForCurrentLevel,
    int? xpRequiredForNextLevel,
    String? activeTileThemeId,
    List<String>? unlockedTileThemeIds,
    int? loginStreak,
    DateTime? lastLoginDate,
  }) {
    return PlayerProfile(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      xpForCurrentLevel: xpForCurrentLevel ?? this.xpForCurrentLevel,
      xpRequiredForNextLevel: xpRequiredForNextLevel ?? this.xpRequiredForNextLevel,
      activeTileThemeId: activeTileThemeId ?? this.activeTileThemeId,
      unlockedTileThemeIds: unlockedTileThemeIds ?? this.unlockedTileThemeIds,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'activeTileThemeId': activeTileThemeId,
        'unlockedTileThemeIds': unlockedTileThemeIds,
        'loginStreak': loginStreak,
        'lastLoginDate': lastLoginDate?.toIso8601String(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final totalXp = (json['totalXp'] as num?)?.toInt() ?? 0;
    final activeTileThemeId = json['activeTileThemeId'] as String? ?? 'classic';
    final unlockedRaw = json['unlockedTileThemeIds'];
    final unlockedTileThemeIds = unlockedRaw is List
        ? (unlockedRaw).map((e) => e.toString()).toList()
        : <String>['classic'];
    final loginStreak = (json['loginStreak'] as num?)?.toInt() ?? 0;
    final lastLoginDate = json['lastLoginDate'] != null
        ? DateTime.tryParse(json['lastLoginDate'] as String)
        : null;

    return PlayerProfile.fromTotalXp(
      totalXp: totalXp,
      activeTileThemeId: activeTileThemeId,
      unlockedTileThemeIds: unlockedTileThemeIds,
      loginStreak: loginStreak,
      lastLoginDate: lastLoginDate,
    );
  }

  @override
  List<Object?> get props => [
        totalXp,
        level,
        xpForCurrentLevel,
        xpRequiredForNextLevel,
        activeTileThemeId,
        unlockedTileThemeIds,
        loginStreak,
        lastLoginDate,
      ];
}
