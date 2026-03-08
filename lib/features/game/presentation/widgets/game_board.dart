import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/board.dart';
import 'tile_widget.dart';

class GameBoard extends StatelessWidget {
  final Board board;
  final bool isHammerMode;
  final ValueChanged<String>? onTileTap;

  const GameBoard({
    super.key,
    required this.board,
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

        return Container(
          width: boardSize,
          height: boardSize,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.gridBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cardBorder.withAlpha(80),
              width: 1.5,
            ),
            boxShadow: [
              // Outer ambient glow
              BoxShadow(
                color: AppColors.primary.withAlpha(12),
                blurRadius: 30,
                spreadRadius: 4,
              ),
              // Inner depth shadow
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Empty cells with subtle inner shadows
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
                      borderRadius: BorderRadius.circular(cellSize * 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Tiles with smooth cubic movement
              ...board.tiles.map((tile) {
                return AnimatedPositioned(
                  key: ValueKey(tile.id),
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
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
        );
      },
    );
  }
}
