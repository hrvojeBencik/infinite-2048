import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// All analytics event names in one place.
/// Keeps naming consistent and makes it easy to audit what we track.
abstract class AnalyticsEvents {
  // --- Game: Story Mode ---
  static const levelStarted = 'level_started';
  static const levelCompleted = 'level_completed';
  static const levelFailed = 'level_failed';
  static const levelRestarted = 'level_restarted';
  static const levelAbandoned = 'level_abandoned';

  // --- Game: Endless Mode ---
  static const endlessStarted = 'endless_started';
  static const endlessGameOver = 'endless_game_over';
  static const endlessRestarted = 'endless_restarted';

  // --- Challenges ---
  static const dailyChallengeStarted = 'daily_challenge_started';
  static const dailyChallengeCompleted = 'daily_challenge_completed';
  static const weeklyChallengeStarted = 'weekly_challenge_started';
  static const weeklyChallengeCompleted = 'weekly_challenge_completed';

  // --- Power-ups ---
  static const powerUpUsed = 'power_up_used';

  // --- Navigation / Engagement ---
  static const zoneSelected = 'zone_selected';
  static const levelSelected = 'level_selected';
  static const settingChanged = 'setting_changed';
  static const themeChanged = 'theme_changed';

  // --- Monetization ---
  static const adWatched = 'ad_watched';
  static const paywallOpened = 'paywall_opened';
  static const paywallDismissed = 'paywall_dismissed';
  static const purchaseStarted = 'purchase_started';
  static const purchaseCompleted = 'purchase_completed';
  static const purchaseRestored = 'purchase_restored';

  // --- Achievements ---
  static const achievementUnlocked = 'achievement_unlocked';

  // --- Engagement ---
  static const loginStreak = 'login_streak';
  static const tutorialCompleted = 'tutorial_completed';
  static const tutorialSkipped = 'tutorial_skipped';
  static const continueAfterLoss = 'continue_after_loss';

  // --- Sharing ---
  static const shareScore = 'share_score';
}

/// Power-up type values for [AnalyticsEvents.powerUpUsed].
abstract class AnalyticsPowerUp {
  static const undo = 'undo';
  static const hammer = 'hammer';
  static const shuffle = 'shuffle';
  static const mergeBoost = 'merge_boost';
}

/// Ad type values for [AnalyticsEvents.adWatched].
abstract class AnalyticsAdType {
  static const rewardedUndo = 'rewarded_undo';
  static const rewardedContinue = 'rewarded_continue';
  static const interstitial = 'interstitial';
}

class AnalyticsService {
  FirebaseAnalytics? _analytics;

  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);
    } catch (e) {
      debugPrint('Analytics init failed: $e');
    }
  }

  FirebaseAnalyticsObserver? get observer {
    if (_analytics == null) return null;
    return FirebaseAnalyticsObserver(analytics: _analytics!);
  }

  // ---------------------------------------------------------------------------
  // Core helper — every event flows through here
  // ---------------------------------------------------------------------------

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Game: Story Mode
  // ---------------------------------------------------------------------------

  Future<void> logLevelStarted({
    required String levelId,
    required int boardSize,
    required int targetTile,
    bool isDailyChallenge = false,
  }) => _log(AnalyticsEvents.levelStarted, {
    'level_id': levelId,
    'board_size': boardSize,
    'target_tile': targetTile,
    'is_daily_challenge': isDailyChallenge ? 1 : 0,
  });

  Future<void> logLevelCompleted({
    required String levelId,
    required int score,
    required int stars,
    required int moves,
    required int highestTile,
  }) => _log(AnalyticsEvents.levelCompleted, {
    'level_id': levelId,
    'score': score,
    'stars': stars,
    'moves': moves,
    'highest_tile': highestTile,
  });

  Future<void> logLevelFailed({
    required String levelId,
    required int score,
    required int moves,
    required int highestTile,
  }) => _log(AnalyticsEvents.levelFailed, {
    'level_id': levelId,
    'score': score,
    'moves': moves,
    'highest_tile': highestTile,
  });

  Future<void> logLevelRestarted({required String levelId}) =>
      _log(AnalyticsEvents.levelRestarted, {'level_id': levelId});

  Future<void> logLevelAbandoned({
    required String levelId,
    required int score,
    required int moves,
  }) => _log(AnalyticsEvents.levelAbandoned, {
    'level_id': levelId,
    'score': score,
    'moves': moves,
  });

  // ---------------------------------------------------------------------------
  // Game: Endless Mode
  // ---------------------------------------------------------------------------

  Future<void> logEndlessStarted() => _log(AnalyticsEvents.endlessStarted);

  Future<void> logEndlessGameOver({
    required int score,
    required int moves,
    required int highestTile,
    required bool isNewRecord,
  }) => _log(AnalyticsEvents.endlessGameOver, {
    'score': score,
    'moves': moves,
    'highest_tile': highestTile,
    'is_new_record': isNewRecord ? 1 : 0,
  });

  Future<void> logEndlessRestarted() => _log(AnalyticsEvents.endlessRestarted);

  // ---------------------------------------------------------------------------
  // Challenges
  // ---------------------------------------------------------------------------

  Future<void> logDailyChallengeStarted() =>
      _log(AnalyticsEvents.dailyChallengeStarted);

  Future<void> logDailyChallengeCompleted({required int score}) =>
      _log(AnalyticsEvents.dailyChallengeCompleted, {'score': score});

  Future<void> logWeeklyChallengeStarted() =>
      _log(AnalyticsEvents.weeklyChallengeStarted);

  Future<void> logWeeklyChallengeCompleted({required int score}) =>
      _log(AnalyticsEvents.weeklyChallengeCompleted, {'score': score});

  // ---------------------------------------------------------------------------
  // Power-ups
  // ---------------------------------------------------------------------------

  Future<void> logPowerUpUsed({required String powerUp, String? context}) =>
      _log(AnalyticsEvents.powerUpUsed, {'type': powerUp, 'context': ?context});

  // ---------------------------------------------------------------------------
  // Navigation / Engagement
  // ---------------------------------------------------------------------------

  Future<void> logZoneSelected({required String zoneId}) =>
      _log(AnalyticsEvents.zoneSelected, {'zone_id': zoneId});

  Future<void> logLevelSelected({required String levelId}) =>
      _log(AnalyticsEvents.levelSelected, {'level_id': levelId});

  Future<void> logSettingChanged({
    required String setting,
    required String value,
  }) => _log(AnalyticsEvents.settingChanged, {
    'setting': setting,
    'value': value,
  });

  Future<void> logThemeChanged({required String themeId}) =>
      _log(AnalyticsEvents.themeChanged, {'theme_id': themeId});

  Future<void> logTutorialCompleted({required int levelNumber}) =>
      _log(AnalyticsEvents.tutorialCompleted, {'level_number': levelNumber});

  Future<void> logTutorialSkipped({required int levelNumber}) =>
      _log(AnalyticsEvents.tutorialSkipped, {'level_number': levelNumber});

  // ---------------------------------------------------------------------------
  // Monetization
  // ---------------------------------------------------------------------------

  Future<void> logAdWatched({required String type}) =>
      _log(AnalyticsEvents.adWatched, {'ad_type': type});

  Future<void> logPaywallOpened({String? source}) =>
      _log(AnalyticsEvents.paywallOpened, {'source': ?source});

  Future<void> logPaywallDismissed({String? source}) =>
      _log(AnalyticsEvents.paywallDismissed, {'source': ?source});

  Future<void> logPurchaseStarted({required String productId}) =>
      _log(AnalyticsEvents.purchaseStarted, {'product_id': productId});

  Future<void> logPurchaseCompleted({required String productId}) =>
      _log(AnalyticsEvents.purchaseCompleted, {'product_id': productId});

  Future<void> logPurchaseRestored() => _log(AnalyticsEvents.purchaseRestored);

  // ---------------------------------------------------------------------------
  // Achievements
  // ---------------------------------------------------------------------------

  Future<void> logAchievementUnlocked({required String achievementId}) async {
    try {
      await _analytics?.logUnlockAchievement(id: achievementId);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Engagement
  // ---------------------------------------------------------------------------

  Future<void> logAppOpened() async {
    try {
      await _analytics?.logAppOpen();
    } catch (_) {}
  }

  Future<void> logLoginStreakDay({required int streakDay}) =>
      _log(AnalyticsEvents.loginStreak, {'day': streakDay});

  Future<void> logShareScore({required String source, String? levelId}) => _log(
    AnalyticsEvents.shareScore,
    {'source': source, 'level_id': ?levelId},
  );

  Future<void> logContinueAfterLoss({
    required String source,
    String? levelId,
  }) => _log(AnalyticsEvents.continueAfterLoss, {
    'source': source,
    'level_id': ?levelId,
  });
}
