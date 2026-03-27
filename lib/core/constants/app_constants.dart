import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = '2048: Merge Quest';

  static const String hiveGameStateBox = 'game_state';
  static const String hiveLevelProgressBox = 'level_progress';
  static const String hiveAchievementsBox = 'achievements';
  static const String hiveSettingsBox = 'settings';
  static const String hiveUserBox = 'user';

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

  static const Duration cloudSyncDebounce = Duration(seconds: 30);
  static const Duration staleDataThreshold = Duration(minutes: 5);

  // RevenueCat API keys (public app-specific keys — safe to commit)
  static const String revenueCatAppleApiKey = 'appl_PLACEHOLDER_REPLACE_ME';
  static const String revenueCatGoogleApiKey = 'goog_PLACEHOLDER_REPLACE_ME';
  static const String premiumEntitlementId = 'premium';
}
