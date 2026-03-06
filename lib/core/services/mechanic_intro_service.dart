import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/game/domain/entities/special_tile_type.dart';
import '../../features/levels/domain/entities/level.dart';

class MechanicIntroService {
  static const _seenKeyPrefix = 'mechanic_seen_';

  Box get _box => Hive.box(AppConstants.hiveSettingsBox);

  List<SpecialTileType> getUnseenMechanicsForLevel(Level level) {
    final unseen = <SpecialTileType>[];

    for (final entry in level.specialTileSpawnRates.entries) {
      if (entry.key == SpecialTileType.none) continue;
      if (entry.value <= 0) continue;
      if (!_hasSeen(entry.key)) {
        unseen.add(entry.key);
      }
    }

    if (level.blockerPositions.isNotEmpty && !_hasSeen(SpecialTileType.blocker)) {
      unseen.add(SpecialTileType.blocker);
    }

    return unseen;
  }

  bool _hasSeen(SpecialTileType type) {
    return _box.get('$_seenKeyPrefix${type.name}', defaultValue: false) as bool;
  }

  Future<void> markSeen(List<SpecialTileType> types) async {
    for (final type in types) {
      await _box.put('$_seenKeyPrefix${type.name}', true);
    }
  }
}
