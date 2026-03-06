import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';

class OnboardingLocalDataSource {
  static const String _keyTutorialCompleted = 'tutorial_completed';
  static const String _keyLastTutorialStep = 'tutorial_last_step';

  Box get _box => Hive.box(AppConstants.hiveSettingsBox);

  bool hasCompletedTutorial() {
    return _box.get(_keyTutorialCompleted, defaultValue: false) as bool;
  }

  Future<void> markTutorialCompleted() async {
    await _box.put(_keyTutorialCompleted, true);
  }

  int getLastTutorialStep() {
    return _box.get(_keyLastTutorialStep, defaultValue: -1) as int;
  }

  Future<void> saveLastTutorialStep(int step) async {
    await _box.put(_keyLastTutorialStep, step);
  }

  Future<void> resetTutorial() async {
    await _box.delete(_keyTutorialCompleted);
    await _box.delete(_keyLastTutorialStep);
  }
}
