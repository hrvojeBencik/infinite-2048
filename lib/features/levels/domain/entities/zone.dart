import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/special_tile_type.dart';
import 'level.dart';

class GameZone extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final List<SpecialTileType> specialTileTypes;
  final List<Level> levels;
  final bool isLocked;
  final int requiredStarsToUnlock;

  const GameZone({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.specialTileTypes = const [],
    this.levels = const [],
    this.isLocked = true,
    this.requiredStarsToUnlock = 0,
  });

  int get totalStars => levels.fold(0, (sum, l) => sum + l.starsEarned);
  int get maxStars => levels.length * 3;
  int get completedLevels => levels.where((l) => l.isCompleted).length;
  double get completionPercentage =>
      levels.isEmpty ? 0 : completedLevels / levels.length;

  GameZone copyWith({
    List<Level>? levels,
    bool? isLocked,
  }) {
    return GameZone(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      specialTileTypes: specialTileTypes,
      levels: levels ?? this.levels,
      isLocked: isLocked ?? this.isLocked,
      requiredStarsToUnlock: requiredStarsToUnlock,
    );
  }

  @override
  List<Object?> get props => [id, name, isLocked];
}
