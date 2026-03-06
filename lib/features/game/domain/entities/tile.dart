import 'package:equatable/equatable.dart';
import 'special_tile_type.dart';

class Tile extends Equatable {
  final String id;
  final int value;
  final int row;
  final int col;
  final SpecialTileType specialType;
  final bool isFrozen;
  final int frozenTurns;
  final bool wasMerged;
  final bool wasSpawned;

  const Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.specialType = SpecialTileType.none,
    this.isFrozen = false,
    this.frozenTurns = 0,
    this.wasMerged = false,
    this.wasSpawned = false,
  });

  Tile copyWith({
    String? id,
    int? value,
    int? row,
    int? col,
    SpecialTileType? specialType,
    bool? isFrozen,
    int? frozenTurns,
    bool? wasMerged,
    bool? wasSpawned,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      specialType: specialType ?? this.specialType,
      isFrozen: isFrozen ?? this.isFrozen,
      frozenTurns: frozenTurns ?? this.frozenTurns,
      wasMerged: wasMerged ?? this.wasMerged,
      wasSpawned: wasSpawned ?? this.wasSpawned,
    );
  }

  bool get canMove => !isFrozen && specialType != SpecialTileType.blocker;
  bool get canMerge => specialType != SpecialTileType.blocker && !isFrozen;

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'row': row,
        'col': col,
        'specialType': specialType.name,
        'isFrozen': isFrozen,
        'frozenTurns': frozenTurns,
      };

  factory Tile.fromJson(Map<String, dynamic> json) => Tile(
        id: json['id'] as String,
        value: json['value'] as int,
        row: json['row'] as int,
        col: json['col'] as int,
        specialType: SpecialTileType.values.byName(json['specialType'] as String),
        isFrozen: json['isFrozen'] as bool? ?? false,
        frozenTurns: json['frozenTurns'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, value, row, col, specialType, isFrozen, frozenTurns];
}
