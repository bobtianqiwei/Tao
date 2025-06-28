import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/tile.dart';
import 'tile_widget.dart';

class GameBoard extends StatelessWidget {
  final Function(Direction)? onSwipe;

  const GameBoard({super.key, this.onSwipe});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isDarkMode = gameProvider.isDarkMode;
        final gridSize = gameProvider.gridSize;
        final board = gameProvider.board;
        
        // 计算棋盘大小，确保填满分配的网格空间
        final boardSize = MediaQuery.of(context).size.width < MediaQuery.of(context).size.height 
            ? MediaQuery.of(context).size.width 
            : MediaQuery.of(context).size.height;
        final cellSize = boardSize / 28; // 28×28网格
        final tileSize = cellSize; // 每个方块填满一个网格单元格
        
        return Container(
          width: gridSize * cellSize,
          height: gridSize * cellSize,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            border: Border.all(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: GestureDetector(
            onPanUpdate: (details) {
              if (onSwipe != null) {
                final dx = details.delta.dx;
                final dy = details.delta.dy;
                
                if (dx.abs() > dy.abs()) {
                  if (dx > 0) {
                    onSwipe!(Direction.right);
                  } else {
                    onSwipe!(Direction.left);
                  }
                } else {
                  if (dy > 0) {
                    onSwipe!(Direction.down);
                  } else {
                    onSwipe!(Direction.up);
                  }
                }
              }
            },
            child: Stack(
              children: [
                // 棋盘内部网格线
                CustomPaint(
                  painter: BoardGridPainter(
                    gridSize: gridSize,
                    cellSize: cellSize,
                    isDarkMode: isDarkMode,
                  ),
                  size: Size(gridSize * cellSize, gridSize * cellSize),
                ),
                // 游戏方块
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    final row = index ~/ gridSize;
                    final col = index % gridSize;
                    final tile = board[row][col];
                    
                    return TileWidget(
                      tile: tile,
                      size: tileSize,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 棋盘网格绘制器
class BoardGridPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;
  final bool isDarkMode;

  BoardGridPainter({
    required this.gridSize,
    required this.cellSize,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 绘制棋盘内部网格线
    for (int i = 1; i < gridSize; i++) {
      final position = i * cellSize;
      
      // 垂直线
      canvas.drawLine(
        Offset(position, 0),
        Offset(position, size.height),
        paint,
      );
      
      // 水平线
      canvas.drawLine(
        Offset(0, position),
        Offset(size.width, position),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 