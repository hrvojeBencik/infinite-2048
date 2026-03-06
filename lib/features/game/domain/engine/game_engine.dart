import 'dart:math';
import 'package:uuid/uuid.dart';
import '../entities/board.dart';
import '../entities/tile.dart';
import '../entities/move_direction.dart';
import '../entities/special_tile_type.dart';

class MoveResult {
  final Board board;
  final int scoreGained;
  final bool boardChanged;
  final List<String> explodedTileIds;

  const MoveResult({
    required this.board,
    this.scoreGained = 0,
    this.boardChanged = false,
    this.explodedTileIds = const [],
  });
}

class GameEngine {
  static const _uuid = Uuid();
  static final _random = Random();

  static Board createBoard(int size, {List<(int, int)> blockers = const []}) {
    var board = Board(size: size, tiles: []);

    for (final pos in blockers) {
      board = board.copyWith(
        tiles: [
          ...board.tiles,
          Tile(
            id: _uuid.v4(),
            value: 0,
            row: pos.$1,
            col: pos.$2,
            specialType: SpecialTileType.blocker,
          ),
        ],
      );
    }

    board = spawnTile(board);
    board = spawnTile(board);
    return board;
  }

  static Board spawnTile(
    Board board, {
    Map<SpecialTileType, double> spawnRates = const {},
  }) {
    final empty = board.emptyCells;
    if (empty.isEmpty) return board;

    final pos = empty[_random.nextInt(empty.length)];
    final value = _random.nextDouble() < 0.1 ? 4 : 2;
    final specialType = _rollSpecialType(spawnRates);

    final newTile = Tile(
      id: _uuid.v4(),
      value: specialType == SpecialTileType.blocker ? 0 : value,
      row: pos.$1,
      col: pos.$2,
      specialType: specialType,
      isFrozen: specialType == SpecialTileType.ice,
      frozenTurns: specialType == SpecialTileType.ice ? 3 : 0,
      wasSpawned: true,
    );

    return board.copyWith(tiles: [...board.tiles, newTile]);
  }

  static SpecialTileType _rollSpecialType(Map<SpecialTileType, double> rates) {
    final roll = _random.nextDouble();
    double cumulative = 0;
    for (final entry in rates.entries) {
      if (entry.key == SpecialTileType.none) continue;
      cumulative += entry.value;
      if (roll < cumulative) return entry.key;
    }
    return SpecialTileType.none;
  }

  static MoveResult moveTiles(Board board, MoveDirection direction) {
    final size = board.size;
    var tiles = board.tiles.map((t) => t.copyWith(wasMerged: false, wasSpawned: false)).toList();
    int scoreGained = 0;
    bool changed = false;
    List<String> explodedIds = [];

    List<List<Tile?>> grid = _tilesToGrid(tiles, size);
    grid = _rotateForDirection(grid, direction, size);

    for (int row = 0; row < size; row++) {
      final result = _processRow(grid[row], size);
      if (result.changed) changed = true;
      scoreGained += result.scoreGained;
      explodedIds.addAll(result.explodedTileIds);
      grid[row] = result.row;
    }

    grid = _rotateBack(grid, direction, size);

    final newTiles = <Tile>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final tile = grid[r][c];
        if (tile != null) {
          newTiles.add(tile.copyWith(row: r, col: c));
        }
      }
    }

    // Process ice tiles: decrement frozen turns
    final processedTiles = newTiles.map((t) {
      if (t.isFrozen && t.frozenTurns > 0) {
        final remaining = t.frozenTurns - 1;
        return t.copyWith(
          frozenTurns: remaining,
          isFrozen: remaining > 0,
        );
      }
      return t;
    }).toList();

    // Handle bomb explosions
    final afterExplosions = _processBombExplosions(processedTiles, size, explodedIds);

    var newBoard = board.copyWith(
      tiles: afterExplosions,
      score: board.score + scoreGained,
      moveCount: changed ? board.moveCount + 1 : board.moveCount,
    );

    return MoveResult(
      board: newBoard,
      scoreGained: scoreGained,
      boardChanged: changed,
      explodedTileIds: explodedIds,
    );
  }

  static _RowResult _processRow(List<Tile?> row, int size) {
    int scoreGained = 0;
    bool changed = false;
    List<String> explodedIds = [];

    // Separate movable and immovable tiles
    final movable = <Tile>[];
    final immovablePositions = <int, Tile>{};

    for (int i = 0; i < row.length; i++) {
      final tile = row[i];
      if (tile == null) continue;
      if (!tile.canMove) {
        immovablePositions[i] = tile;
      } else {
        movable.add(tile);
      }
    }

    // Merge equal adjacent movable tiles
    final merged = <Tile>[];
    int i = 0;
    while (i < movable.length) {
      if (i + 1 < movable.length && _canMerge(movable[i], movable[i + 1])) {
        final mergeResult = _mergeTiles(movable[i], movable[i + 1]);
        merged.add(mergeResult.tile);
        scoreGained += mergeResult.scoreGained;
        if (mergeResult.isBombExplosion) {
          explodedIds.add(mergeResult.tile.id);
        }
        changed = true;
        i += 2;
      } else {
        merged.add(movable[i]);
        i++;
      }
    }

    // Place tiles back into row respecting immovable positions
    final result = List<Tile?>.filled(size, null);
    for (final entry in immovablePositions.entries) {
      result[entry.key] = entry.value;
    }

    int mergedIdx = 0;
    for (int j = 0; j < size; j++) {
      if (result[j] != null) continue;
      if (mergedIdx < merged.length) {
        result[j] = merged[mergedIdx];
        mergedIdx++;
      }
    }

    // Check if anything actually moved
    if (!changed) {
      for (int j = 0; j < size; j++) {
        if (row[j]?.id != result[j]?.id) {
          changed = true;
          break;
        }
      }
    }

    return _RowResult(
      row: result,
      scoreGained: scoreGained,
      changed: changed,
      explodedTileIds: explodedIds,
    );
  }

  static bool _canMerge(Tile a, Tile b) {
    if (!a.canMerge || !b.canMerge) return false;
    if (a.specialType == SpecialTileType.wildcard ||
        b.specialType == SpecialTileType.wildcard) {
      return true;
    }
    return a.value == b.value;
  }

  static _MergeResult _mergeTiles(Tile a, Tile b) {
    int newValue;
    bool isBomb = a.specialType == SpecialTileType.bomb ||
        b.specialType == SpecialTileType.bomb;
    bool isMultiplier = a.specialType == SpecialTileType.multiplier ||
        b.specialType == SpecialTileType.multiplier;

    if (isBomb) {
      final baseValue = a.specialType == SpecialTileType.bomb ? b.value : a.value;
      newValue = (baseValue == 0 ? a.value + b.value : baseValue) * 2;
    } else if (a.specialType == SpecialTileType.wildcard) {
      newValue = b.value * 2;
    } else if (b.specialType == SpecialTileType.wildcard) {
      newValue = a.value * 2;
    } else if (isMultiplier) {
      newValue = a.value * 4;
    } else {
      newValue = a.value * 2;
    }

    final scoreGained = isMultiplier ? newValue * 2 : newValue;

    final mergedTile = Tile(
      id: a.id,
      value: newValue,
      row: a.row,
      col: a.col,
      wasMerged: true,
      specialType: SpecialTileType.none,
    );

    return _MergeResult(
      tile: mergedTile,
      scoreGained: scoreGained,
      isBombExplosion: isBomb,
    );
  }

  static List<Tile> _processBombExplosions(
      List<Tile> tiles, int size, List<String> explodedIds) {
    if (explodedIds.isEmpty) return tiles;

    final toRemove = <String>{};
    for (final bombId in explodedIds) {
      final bomb = tiles.where((t) => t.id == bombId).firstOrNull;
      if (bomb == null) continue;
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = bomb.row + dr;
          final nc = bomb.col + dc;
          if (nr < 0 || nr >= size || nc < 0 || nc >= size) continue;
          final target = tiles.where((t) => t.row == nr && t.col == nc).firstOrNull;
          if (target != null && target.specialType != SpecialTileType.blocker) {
            toRemove.add(target.id);
          }
        }
      }
      toRemove.add(bombId);
    }

    return tiles.where((t) => !toRemove.contains(t.id)).toList();
  }

  static bool hasValidMoves(Board board) {
    final size = board.size;
    if (board.emptyCells.isNotEmpty) return true;

    for (final tile in board.tiles) {
      if (!tile.canMerge) continue;
      for (final dir in [(0, 1), (1, 0)]) {
        final nr = tile.row + dir.$1;
        final nc = tile.col + dir.$2;
        if (nr >= size || nc >= size) continue;
        final neighbor = board.tileAt(nr, nc);
        if (neighbor != null && _canMerge(tile, neighbor)) {
          return true;
        }
      }
    }
    return false;
  }

  static Board shuffleBoard(Board board) {
    final movableTiles = board.tiles.where((t) => t.canMove).toList();
    final immovableTiles = board.tiles.where((t) => !t.canMove).toList();

    final occupied = immovableTiles.map((t) => (t.row, t.col)).toSet();
    final available = <(int, int)>[];
    for (int r = 0; r < board.size; r++) {
      for (int c = 0; c < board.size; c++) {
        if (!occupied.contains((r, c))) available.add((r, c));
      }
    }
    available.shuffle(_random);

    final shuffled = <Tile>[];
    for (int i = 0; i < movableTiles.length && i < available.length; i++) {
      shuffled.add(movableTiles[i].copyWith(
        row: available[i].$1,
        col: available[i].$2,
      ));
    }

    return board.copyWith(tiles: [...immovableTiles, ...shuffled]);
  }

  static Board removeTile(Board board, String tileId) {
    return board.copyWith(
      tiles: board.tiles.where((t) => t.id != tileId).toList(),
    );
  }

  // Grid transformation helpers
  static List<List<Tile?>> _tilesToGrid(List<Tile> tiles, int size) {
    final grid = List.generate(size, (_) => List<Tile?>.filled(size, null));
    for (final tile in tiles) {
      if (tile.row < size && tile.col < size) {
        grid[tile.row][tile.col] = tile;
      }
    }
    return grid;
  }

  static List<List<Tile?>> _rotateForDirection(
      List<List<Tile?>> grid, MoveDirection dir, int size) {
    switch (dir) {
      case MoveDirection.left:
        return grid;
      case MoveDirection.right:
        return grid.map((row) => row.reversed.toList()).toList();
      case MoveDirection.up:
        return _transpose(grid, size);
      case MoveDirection.down:
        return _transpose(grid, size)
            .map((row) => row.reversed.toList())
            .toList();
    }
  }

  static List<List<Tile?>> _rotateBack(
      List<List<Tile?>> grid, MoveDirection dir, int size) {
    switch (dir) {
      case MoveDirection.left:
        return grid;
      case MoveDirection.right:
        return grid.map((row) => row.reversed.toList()).toList();
      case MoveDirection.up:
        return _transpose(grid, size);
      case MoveDirection.down:
        return _transpose(
            grid.map((row) => row.reversed.toList()).toList(), size);
    }
  }

  static List<List<Tile?>> _transpose(List<List<Tile?>> grid, int size) {
    return List.generate(
      size,
      (r) => List.generate(size, (c) => grid[c][r]),
    );
  }
}

class _RowResult {
  final List<Tile?> row;
  final int scoreGained;
  final bool changed;
  final List<String> explodedTileIds;

  const _RowResult({
    required this.row,
    this.scoreGained = 0,
    this.changed = false,
    this.explodedTileIds = const [],
  });
}

class _MergeResult {
  final Tile tile;
  final int scoreGained;
  final bool isBombExplosion;

  const _MergeResult({
    required this.tile,
    this.scoreGained = 0,
    this.isBombExplosion = false,
  });
}
