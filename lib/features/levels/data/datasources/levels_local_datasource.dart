import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../game/domain/entities/special_tile_type.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/zone.dart';

class LevelsLocalDataSource {
  Box get _progressBox => Hive.box(AppConstants.hiveLevelProgressBox);

  List<GameZone> getZones() {
    return _buildZones();
  }

  List<Level> getLevelsForZone(String zoneId) {
    final zones = _buildZones();
    final zone = zones.where((z) => z.id == zoneId).firstOrNull;
    if (zone == null) return [];
    return _applyProgress(zone.levels);
  }

  Level? getLevel(String levelId) {
    final zones = _buildZones();
    for (final zone in zones) {
      for (final level in zone.levels) {
        if (level.id == levelId) {
          return _applyProgressToLevel(level);
        }
      }
    }
    return null;
  }

  Future<void> saveLevelProgress({
    required String levelId,
    required int score,
    required int stars,
  }) async {
    final existing = _progressBox.get(levelId);
    Map<String, dynamic> data = {};
    if (existing != null) {
      data = jsonDecode(existing as String) as Map<String, dynamic>;
    }
    final prevScore = data['bestScore'] as int? ?? 0;
    final prevStars = data['starsEarned'] as int? ?? 0;
    data['isCompleted'] = true;
    data['bestScore'] = score > prevScore ? score : prevScore;
    data['starsEarned'] = stars > prevStars ? stars : prevStars;
    await _progressBox.put(levelId, jsonEncode(data));
  }

  Map<String, dynamic>? getLevelProgress(String levelId) {
    final data = _progressBox.get(levelId);
    if (data == null) return null;
    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  int getTotalStars() {
    int total = 0;
    for (final key in _progressBox.keys) {
      final data = _progressBox.get(key);
      if (data != null) {
        final map = jsonDecode(data as String) as Map<String, dynamic>;
        total += (map['starsEarned'] as int? ?? 0);
      }
    }
    return total;
  }

  List<Level> _applyProgress(List<Level> levels) {
    return levels.map(_applyProgressToLevel).toList();
  }

  Level _applyProgressToLevel(Level level) {
    final data = getLevelProgress(level.id);
    if (data == null) return level;
    return level.copyWith(
      isCompleted: data['isCompleted'] as bool? ?? false,
      bestScore: data['bestScore'] as int? ?? 0,
      starsEarned: data['starsEarned'] as int? ?? 0,
    );
  }

  // Hard-coded zone and level definitions
  List<GameZone> _buildZones() {
    return [
      GameZone(
        id: 'genesis',
        name: 'Genesis',
        description: 'Master the fundamentals',
        iconName: 'auto_awesome',
        specialTileTypes: const [],
        isLocked: false,
        requiredStarsToUnlock: 0,
        levels: _genesisLevels(),
      ),
      GameZone(
        id: 'inferno',
        name: 'Inferno',
        description: 'Explosive new mechanics',
        iconName: 'local_fire_department',
        specialTileTypes: const [SpecialTileType.bomb],
        isLocked: false,
        requiredStarsToUnlock: 15,
        levels: _infernoLevels(),
      ),
      GameZone(
        id: 'glacier',
        name: 'Glacier',
        description: 'Frozen challenges await',
        iconName: 'ac_unit',
        specialTileTypes: const [SpecialTileType.ice],
        isLocked: false,
        requiredStarsToUnlock: 30,
        levels: _glacierLevels(),
      ),
      GameZone(
        id: 'nexus',
        name: 'Nexus',
        description: 'Multiply your power',
        iconName: 'flash_on',
        specialTileTypes: const [
          SpecialTileType.multiplier,
          SpecialTileType.wildcard,
        ],
        isLocked: false,
        requiredStarsToUnlock: 50,
        levels: _nexusLevels(),
      ),
      GameZone(
        id: 'void',
        name: 'The Void',
        description: 'Ultimate challenge',
        iconName: 'blur_on',
        specialTileTypes: SpecialTileType.values
            .where((t) => t != SpecialTileType.none)
            .toList(),
        isLocked: false,
        requiredStarsToUnlock: 75,
        levels: _voidLevels(),
      ),
    ];
  }

  List<Level> _genesisLevels() => [
        for (int i = 1; i <= 10; i++)
          Level(
            id: 'genesis_$i',
            zoneId: 'genesis',
            levelNumber: i,
            boardSize: i <= 3 ? 3 : 4,
            targetTileValue: _genesisTargets[i - 1],
            starThreshold2: _genesisTargets[i - 1] * 2,
            starThreshold3: _genesisTargets[i - 1] * 4,
          ),
      ];

  static const _genesisTargets = [32, 64, 64, 128, 128, 256, 256, 512, 1024, 2048];

  List<Level> _infernoLevels() => [
        for (int i = 1; i <= 10; i++)
          Level(
            id: 'inferno_$i',
            zoneId: 'inferno',
            levelNumber: 10 + i,
            boardSize: i <= 5 ? 4 : 5,
            targetTileValue: _infernoTargets[i - 1],
            specialTileSpawnRates: const {SpecialTileType.bomb: 0.08},
            starThreshold2: _infernoTargets[i - 1] * 3,
            starThreshold3: _infernoTargets[i - 1] * 5,
          ),
      ];

  static const _infernoTargets = [256, 512, 512, 1024, 1024, 2048, 2048, 2048, 4096, 4096];

  List<Level> _glacierLevels() => [
        for (int i = 1; i <= 10; i++)
          Level(
            id: 'glacier_$i',
            zoneId: 'glacier',
            levelNumber: 20 + i,
            boardSize: i <= 5 ? 4 : 5,
            targetTileValue: _glacierTargets[i - 1],
            moveLimit: i > 5 ? 100 + (10 - i) * 10 : null,
            specialTileSpawnRates: const {SpecialTileType.ice: 0.12},
            starThreshold2: _glacierTargets[i - 1] * 3,
            starThreshold3: _glacierTargets[i - 1] * 6,
          ),
      ];

  static const _glacierTargets = [512, 512, 1024, 1024, 2048, 2048, 4096, 4096, 8192, 8192];

  List<Level> _nexusLevels() => [
        for (int i = 1; i <= 10; i++)
          Level(
            id: 'nexus_$i',
            zoneId: 'nexus',
            levelNumber: 30 + i,
            boardSize: i <= 5 ? 5 : 6,
            targetTileValue: _nexusTargets[i - 1],
            specialTileSpawnRates: const {
              SpecialTileType.multiplier: 0.06,
              SpecialTileType.wildcard: 0.04,
            },
            starThreshold2: _nexusTargets[i - 1] * 4,
            starThreshold3: _nexusTargets[i - 1] * 7,
          ),
      ];

  static const _nexusTargets = [1024, 2048, 2048, 4096, 4096, 8192, 8192, 16384, 16384, 16384];

  List<Level> _voidLevels() => [
        for (int i = 1; i <= 10; i++)
          Level(
            id: 'void_$i',
            zoneId: 'void',
            levelNumber: 40 + i,
            boardSize: i <= 5 ? 6 : 7,
            targetTileValue: _voidTargets[i - 1],
            moveLimit: i > 7 ? 150 : null,
            timeLimitSeconds: i > 8 ? 300 : null,
            specialTileSpawnRates: const {
              SpecialTileType.bomb: 0.05,
              SpecialTileType.ice: 0.08,
              SpecialTileType.multiplier: 0.04,
              SpecialTileType.wildcard: 0.03,
            },
            starThreshold2: _voidTargets[i - 1] * 5,
            starThreshold3: _voidTargets[i - 1] * 8,
          ),
      ];

  static const _voidTargets = [4096, 8192, 8192, 16384, 16384, 32768, 32768, 65536, 65536, 65536];
}
