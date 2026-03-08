import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = '2048: Merge Quest';

  static const String hiveGameStateBox = 'game_state';
  static const String hiveLevelProgressBox = 'level_progress';
  static const String hiveAchievementsBox = 'achievements';
  static const String hiveSettingsBox = 'settings';
  static const String hiveUserBox = 'user';

  static const String revenueCatApiKeyIos = 'test_qGujcKEIroDcOteFaPjjhOeZAbG';
  static const String revenueCatApiKeyAndroid =
      'test_qGujcKEIroDcOteFaPjjhOeZAbG';
  static const String revenueCatEntitlementId = '2048: Merge Quest Pro';

  static const String adMobBannerIdAndroid = kDebugMode
      ? 'ca-app-pub-3940256099942544/9214589741'
      : 'ca-app-pub-7471321356104495/1683269527';

  static const String adMobBannerIdIos = kDebugMode
      ? 'ca-app-pub-3940256099942544/2435281174'
      : 'ca-app-pub-7471321356104495/9374057286';

  static const String adMobInterstitialIdAndroid = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-7471321356104495/8771422057';

  static const String adMobInterstitialIdIos = kDebugMode
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-7471321356104495/9494786296';

  static const String adMobRewardedIdAndroid = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-7471321356104495/3834935934';

  static const String adMobRewardedIdIos = kDebugMode
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-7471321356104495/8181704628';

  // Game Center / Google Play Games leaderboard IDs
  // TODO: Replace with real IDs from App Store Connect / Google Play Console
  static const String leaderboardStoryId = 'merge_quest_story';
  static const String leaderboardEndlessId = 'merge_quest_endless';
  static const String leaderboardDailyId = 'merge_quest_daily';
  static const String leaderboardWeeklyId = 'merge_quest_weekly';

  static const Duration cloudSyncDebounce = Duration(seconds: 30);
  static const Duration staleDataThreshold = Duration(minutes: 5);
}
