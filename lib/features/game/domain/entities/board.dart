import 'package:equatable/equatable.dart';
import 'tile.dart';

class Board extends Equatable {
  final int size;
  final List<Tile> tiles;
  final int score;
  final int moveCount;

  const Board({
    required this.size,
    required this.tiles,
    this.score = 0,
    this.moveCount = 0,
  });

  Board copyWith({
    int? size,
    List<Tile>? tiles,
    int? score,
    int? moveCount,
  }) {
    return Board(
      size: size ?? this.size,
      tiles: tiles ?? this.tiles,
      score: score ?? this.score,
      moveCount: moveCount ?? this.moveCount,
    );
  }

  Tile? tileAt(int row, int col) {
    for (final tile in tiles) {
      if (tile.row == row && tile.col == col) return tile;
    }
    return null;
  }

  bool get isFull => tiles.length >= size * size;

  List<(int, int)> get emptyCells {
    final occupied = <(int, int)>{};
    for (final tile in tiles) {
      occupied.add((tile.row, tile.col));
    }
    final empty = <(int, int)>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (!occupied.contains((r, c))) empty.add((r, c));
      }
    }
    return empty;
  }

  int get highestTile {
    if (tiles.isEmpty) return 0;
    return tiles.fold(0, (max, tile) => tile.value > max ? tile.value : max);
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'tiles': tiles.map((t) => t.toJson()).toList(),
        'score': score,
        'moveCount': moveCount,
      };

  factory Board.fromJson(Map<String, dynamic> json) => Board(
        size: json['size'] as int,
        tiles: (json['tiles'] as List)
            .map((t) => Tile.fromJson(t as Map<String, dynamic>))
            .toList(),
        score: json['score'] as int? ?? 0,
        moveCount: json['moveCount'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [size, tiles, score, moveCount];
}
