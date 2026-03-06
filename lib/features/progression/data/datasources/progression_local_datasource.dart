import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/player_profile.dart';

class ProgressionLocalDataSource {
  Box get _box => Hive.box(AppConstants.hiveSettingsBox);

  static const String _profileKey = 'player_profile';

  PlayerProfile getProfile() {
    final data = _box.get(_profileKey);
    if (data == null) return _defaultProfile();

    try {
      final map = jsonDecode(data as String) as Map<String, dynamic>;
      return PlayerProfile.fromJson(map);
    } catch (_) {
      return _defaultProfile();
    }
  }

  Future<void> saveProfile(PlayerProfile profile) async {
    await _box.put(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<int> addXp(int amount) async {
    final profile = getProfile();
    final newTotalXp = profile.totalXp + amount;
    final newProfile = PlayerProfile.fromTotalXp(
      totalXp: newTotalXp,
      activeTileThemeId: profile.activeTileThemeId,
      unlockedTileThemeIds: profile.unlockedTileThemeIds,
      loginStreak: profile.loginStreak,
      lastLoginDate: profile.lastLoginDate,
    );
    await saveProfile(newProfile);
    return newTotalXp;
  }

  Future<void> setActiveTileTheme(String themeId) async {
    final profile = getProfile();
    final newProfile = PlayerProfile.fromTotalXp(
      totalXp: profile.totalXp,
      activeTileThemeId: themeId,
      unlockedTileThemeIds: profile.unlockedTileThemeIds,
      loginStreak: profile.loginStreak,
      lastLoginDate: profile.lastLoginDate,
    );
    await saveProfile(newProfile);
  }

  Future<void> unlockTileTheme(String themeId) async {
    final profile = getProfile();
    if (profile.unlockedTileThemeIds.contains(themeId)) return;

    final updated = List<String>.from(profile.unlockedTileThemeIds)..add(themeId);
    final newProfile = PlayerProfile.fromTotalXp(
      totalXp: profile.totalXp,
      activeTileThemeId: profile.activeTileThemeId,
      unlockedTileThemeIds: updated,
      loginStreak: profile.loginStreak,
      lastLoginDate: profile.lastLoginDate,
    );
    await saveProfile(newProfile);
  }

  Future<void> recordLogin() async {
    final profile = getProfile();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int newStreak;
    if (profile.lastLoginDate == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime(
        profile.lastLoginDate!.year,
        profile.lastLoginDate!.month,
        profile.lastLoginDate!.day,
      );
      if (lastDate == today) {
        newStreak = profile.loginStreak;
      } else if (lastDate == yesterday) {
        newStreak = profile.loginStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    final newProfile = PlayerProfile.fromTotalXp(
      totalXp: profile.totalXp,
      activeTileThemeId: profile.activeTileThemeId,
      unlockedTileThemeIds: profile.unlockedTileThemeIds,
      loginStreak: newStreak,
      lastLoginDate: now,
    );
    await saveProfile(newProfile);
  }

  PlayerProfile _defaultProfile() {
    return PlayerProfile.fromTotalXp(
      totalXp: 0,
      activeTileThemeId: 'classic',
      unlockedTileThemeIds: const ['classic'],
      loginStreak: 0,
      lastLoginDate: null,
    );
  }
}
