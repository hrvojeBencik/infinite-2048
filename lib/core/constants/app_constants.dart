class AppConstants {
  AppConstants._();

  static const String appName = '2048: Merge Quest';
  static const String appVersion = '0.1.0';

  static const String hiveGameStateBox = 'game_state';
  static const String hiveLevelProgressBox = 'level_progress';
  static const String hiveAchievementsBox = 'achievements';
  static const String hiveSettingsBox = 'settings';
  static const String hiveUserBox = 'user';

  static const String revenueCatApiKeyIos = 'YOUR_REVENUECAT_IOS_KEY';
  static const String revenueCatApiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_KEY';
  static const String revenueCatEntitlementId = 'premium';

  static const String adMobBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String adMobBannerIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String adMobInterstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String adMobInterstitialIdIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String adMobRewardedIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String adMobRewardedIdIos = 'ca-app-pub-3940256099942544/1712485313';

  static const Duration cloudSyncDebounce = Duration(seconds: 30);
  static const Duration staleDataThreshold = Duration(minutes: 5);
}
