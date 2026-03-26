import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HapticService {
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
