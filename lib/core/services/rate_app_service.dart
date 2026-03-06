import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import '../constants/app_constants.dart';

class RateAppService {
  static const _keyHasRated = 'has_rated_app';
  static const _keyLevelsCompletedSincePrompt = 'levels_since_rate_prompt';
  static const _keyLastPromptTime = 'last_rate_prompt_time';

  final InAppReview _inAppReview = InAppReview.instance;

  Box get _box => Hive.box(AppConstants.hiveSettingsBox);

  bool get _hasRated => _box.get(_keyHasRated, defaultValue: false) as bool;

  int get _levelsSincePrompt =>
      _box.get(_keyLevelsCompletedSincePrompt, defaultValue: 0) as int;

  /// Whether enough time and engagement has passed to show the prompt.
  /// Triggers after 5 level completions, then every 15 after that, with at
  /// least 3 days between prompts.
  bool shouldPromptForReview() {
    if (_hasRated) return false;

    final lastPrompt = _box.get(_keyLastPromptTime) as int?;
    if (lastPrompt != null) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastPrompt;
      if (elapsed < const Duration(days: 3).inMilliseconds) return false;
    }

    final threshold = lastPrompt == null ? 5 : 15;
    return _levelsSincePrompt >= threshold;
  }

  /// Call after every level completion to track engagement.
  Future<void> recordLevelCompleted({required int stars}) async {
    if (_hasRated) return;
    await _box.put(_keyLevelsCompletedSincePrompt, _levelsSincePrompt + 1);
  }

  /// Request the native in-app review dialog.
  Future<void> requestReview() async {
    await _box.put(
        _keyLastPromptTime, DateTime.now().millisecondsSinceEpoch);
    await _box.put(_keyLevelsCompletedSincePrompt, 0);

    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      await _box.put(_keyHasRated, true);
    }
  }
}
