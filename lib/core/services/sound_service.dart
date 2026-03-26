import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../app/di.dart';
import 'haptic_service.dart';

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
    sl<HapticService>().light();
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
