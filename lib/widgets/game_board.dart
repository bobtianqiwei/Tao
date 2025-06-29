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
                    final tile = board[row][col] as Tile;
                    
                    return TileWidget(
                      tile: tile,
                      size: tileSize,
                      showGlow: false, // Disable glow in tile widget
                    );
                  },
                ),
                // 发光效果覆盖层 - 放在最顶层
                if (gameProvider.showGlowEffect)
                  ...board.asMap().entries.expand((rowEntry) {
                    final row = rowEntry.key;
                    return rowEntry.value.asMap().entries.where((colEntry) {
                      final tile = colEntry.value;
                      return tile.character?.elementType.toString() == 'ElementType.dao';
                    }).map((colEntry) {
                      final col = colEntry.key;
                      return Positioned(
                        left: col * cellSize,
                        top: row * cellSize,
                        child: _GlowOverlay(size: cellSize),
                      );
                    });
                  }),
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
      ..color = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw board internal grid lines
    for (int i = 1; i < gridSize; i++) {
      final position = i * cellSize;
      
      // Vertical lines
      canvas.drawLine(
        Offset(position, 0),
        Offset(position, size.height),
        paint,
      );
      
      // Horizontal lines
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

// 发光效果覆盖层组件
class _GlowOverlay extends StatefulWidget {
  final double size;
  
  const _GlowOverlay({required this.size});
  
  @override
  State<_GlowOverlay> createState() => _GlowOverlayState();
}

class _GlowOverlayState extends State<_GlowOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // 2 minutes
    );
    _glowAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60), // 0-60s full glow
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60), // 60-120s fade out
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(_glowAnimation.value * 0.8),
                blurRadius: 32 * _glowAnimation.value + 8,
                spreadRadius: 8 * _glowAnimation.value + 2,
              ),
            ],
          ),
        );
      },
    );
  }
} 