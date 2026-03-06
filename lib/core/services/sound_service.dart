import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

enum GameSound {
  merge,
  mergeHigh,
  bombExplode,
  iceShatter,
  spawn,
  swipe,
  levelWin,
  levelLose,
  combo,
  buttonTap,
}

class SoundService {
  Box get _box => Hive.box(AppConstants.hiveSettingsBox);
  static const _soundEnabledKey = 'sound_enabled';

  bool get isSoundEnabled => _box.get(_soundEnabledKey, defaultValue: true) as bool;

  Future<void> setSoundEnabled(bool enabled) async {
    await _box.put(_soundEnabledKey, enabled);
  }

  void play(GameSound sound) {
    if (!isSoundEnabled) return;
    // Sound playback will be implemented when audio assets are added.
    // Placeholder: trigger haptic as audio substitute.
    HapticService.instance.light();
  }

  void playMerge(int tileValue) {
    if (!isSoundEnabled) return;
    if (tileValue >= 128) {
      play(GameSound.mergeHigh);
    } else {
      play(GameSound.merge);
    }
  }
}

class HapticService {
  HapticService._();
  static final instance = HapticService._();

  Box get _box => Hive.box(AppConstants.hiveSettingsBox);
  static const _hapticEnabledKey = 'haptic_enabled';

  bool get isEnabled => _box.get(_hapticEnabledKey, defaultValue: true) as bool;

  Future<void> setEnabled(bool enabled) async {
    await _box.put(_hapticEnabledKey, enabled);
  }

  void light() {
    if (!isEnabled) return;
    HapticFeedback.lightImpact();
  }

  void medium() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void selection() {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
  }

  void merge() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void bomb() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void combo() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }
}
