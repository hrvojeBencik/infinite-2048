import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

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

  // --- Navigation ---

  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  // --- Game Events ---

  Future<void> logLevelStarted({
    required String levelId,
    required int boardSize,
    required int targetTile,
  }) async {
    await _analytics?.logEvent(
      name: 'level_started',
      parameters: {
        'level_id': levelId,
        'board_size': boardSize,
        'target_tile': targetTile,
      },
    );
  }

  Future<void> logLevelCompleted({
    required String levelId,
    required int score,
    required int stars,
    required int moves,
    required int highestTile,
  }) async {
    await _analytics?.logEvent(
      name: 'level_completed',
      parameters: {
        'level_id': levelId,
        'score': score,
        'stars': stars,
        'moves': moves,
        'highest_tile': highestTile,
      },
    );
  }

  Future<void> logLevelFailed({
    required String levelId,
    required int score,
    required int moves,
    required int highestTile,
  }) async {
    await _analytics?.logEvent(
      name: 'level_failed',
      parameters: {
        'level_id': levelId,
        'score': score,
        'moves': moves,
        'highest_tile': highestTile,
      },
    );
  }

  // --- Endless Mode ---

  Future<void> logEndlessStarted() async {
    await _analytics?.logEvent(name: 'endless_started');
  }

  Future<void> logEndlessGameOver({
    required int score,
    required int moves,
    required int highestTile,
    required bool isNewRecord,
  }) async {
    await _analytics?.logEvent(
      name: 'endless_game_over',
      parameters: {
        'score': score,
        'moves': moves,
        'highest_tile': highestTile,
        'is_new_record': isNewRecord ? 1 : 0,
      },
    );
  }

  // --- Challenges ---

  Future<void> logDailyChallengeStarted() async {
    await _analytics?.logEvent(name: 'daily_challenge_started');
  }

  Future<void> logDailyChallengeCompleted({required int score}) async {
    await _analytics?.logEvent(
      name: 'daily_challenge_completed',
      parameters: {'score': score},
    );
  }

  Future<void> logWeeklyChallengeStarted() async {
    await _analytics?.logEvent(name: 'weekly_challenge_started');
  }

  Future<void> logWeeklyChallengeCompleted({required int score}) async {
    await _analytics?.logEvent(
      name: 'weekly_challenge_completed',
      parameters: {'score': score},
    );
  }

  // --- Features ---

  Future<void> logThemeChanged({required String themeId}) async {
    await _analytics?.logEvent(
      name: 'theme_changed',
      parameters: {'theme_id': themeId},
    );
  }

  Future<void> logAchievementUnlocked({required String achievementId}) async {
    await _analytics?.logUnlockAchievement(id: achievementId);
  }

  Future<void> logPowerUpUsed({required String powerUp}) async {
    await _analytics?.logEvent(
      name: 'power_up_used',
      parameters: {'type': powerUp},
    );
  }

  // --- Monetization ---

  Future<void> logAdWatched({required String type}) async {
    await _analytics?.logEvent(
      name: 'ad_watched',
      parameters: {'ad_type': type},
    );
  }

  Future<void> logPaywallOpened({String? source}) async {
    await _analytics?.logEvent(
      name: 'paywall_opened',
      parameters: {'source': ?source},
    );
  }

  Future<void> logPaywallDismissed({String? source}) async {
    await _analytics?.logEvent(
      name: 'paywall_dismissed',
      parameters: {'source': ?source},
    );
  }

  Future<void> logPurchaseStarted({required String productId}) async {
    await _analytics?.logEvent(
      name: 'purchase_started',
      parameters: {'product_id': productId},
    );
  }

  // --- Engagement ---

  Future<void> logAppOpened() async {
    await _analytics?.logAppOpen();
  }

  Future<void> logLoginStreakDay({required int streakDay}) async {
    await _analytics?.logEvent(
      name: 'login_streak',
      parameters: {'day': streakDay},
    );
  }
}
