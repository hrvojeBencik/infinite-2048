import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Wrapper around games_services package for Game Center (iOS)
/// and Google Play Games Services (Android).
class GamesService {
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  Box get _userBox => Hive.box(AppConstants.hiveUserBox);

  /// Attempt to sign in to Game Center / Google Play Games.
  /// Returns true if sign-in was successful.
  Future<bool> signIn() async {
    try {
      await GamesServices.signIn();
      _isSignedIn = true;
      await _userBox.put('gamesServicesConnected', true);
      return true;
    } catch (e) {
      debugPrint('Games Services sign-in failed: $e');
      _isSignedIn = false;
      return false;
    }
  }

  /// Check if already signed in (e.g. on app start).
  Future<bool> checkSignInStatus() async {
    try {
      final signedIn = await GamesServices.isSignedIn;
      _isSignedIn = signedIn;
      if (signedIn) {
        await _userBox.put('gamesServicesConnected', true);
      }
      return signedIn;
    } catch (e) {
      debugPrint('Games Services status check failed: $e');
      _isSignedIn = false;
      return false;
    }
  }

  /// Submit a score to the native leaderboard.
  Future<void> submitScore({
    required int score,
    required String leaderboardId,
  }) async {
    if (!_isSignedIn) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          iOSLeaderboardID: leaderboardId,
          androidLeaderboardID: leaderboardId,
          value: score,
        ),
      );
    } catch (e) {
      debugPrint('Games Services score submit failed: $e');
    }
  }

  /// Show the native leaderboard UI.
  Future<void> showLeaderboards({String? leaderboardId}) async {
    if (!_isSignedIn) return;
    try {
      await GamesServices.showLeaderboards(
        iOSLeaderboardID: leaderboardId ?? AppConstants.leaderboardStoryId,
        androidLeaderboardID:
            leaderboardId ?? AppConstants.leaderboardStoryId,
      );
    } catch (e) {
      debugPrint('Games Services show leaderboards failed: $e');
    }
  }

  /// Show the native achievements UI.
  Future<void> showAchievements() async {
    if (!_isSignedIn) return;
    try {
      await GamesServices.showAchievements();
    } catch (e) {
      debugPrint('Games Services show achievements failed: $e');
    }
  }
}
