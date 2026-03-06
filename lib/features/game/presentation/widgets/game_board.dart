import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/move_direction.dart';
import 'tile_widget.dart';

class GameBoard extends StatelessWidget {
  final Board board;
  final bool isHammerMode;
  final ValueChanged<MoveDirection> onSwipe;
  final ValueChanged<String>? onTileTap;

  const GameBoard({
    super.key,
    required this.board,
    required this.onSwipe,
    this.isHammerMode = false,
    this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final padding = boardSize * 0.02;
        final cellSize = (boardSize - padding * 2) / board.size;

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 0) {
              onSwipe(MoveDirection.right);
            } else {
              onSwipe(MoveDirection.left);
            }
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 0) {
              onSwipe(MoveDirection.down);
            } else {
              onSwipe(MoveDirection.up);
            }
          },
          child: Container(
            width: boardSize,
            height: boardSize,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.gridBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(20),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Empty cell backgrounds
                ...List.generate(board.size * board.size, (index) {
                  final row = index ~/ board.size;
                  final col = index % board.size;
                  return Positioned(
                    left: col * cellSize + 2,
                    top: row * cellSize + 2,
                    child: Container(
                      width: cellSize - 4,
                      height: cellSize - 4,
                      decoration: BoxDecoration(
                        color: AppColors.cellEmpty,
                        borderRadius: BorderRadius.circular(cellSize * 0.1),
                      ),
                    ),
                  );
                }),
                // Tile widgets
                ...board.tiles.map((tile) {
                  return AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    left: tile.col * cellSize + 2,
                    top: tile.row * cellSize + 2,
                    child: TileWidget(
                      tile: tile,
                      cellSize: cellSize,
                      isHammerMode: isHammerMode,
                      onTap: isHammerMode ? () => onTileTap?.call(tile.id) : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
