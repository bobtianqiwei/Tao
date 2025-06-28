import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/grid_cell.dart';
import '../widgets/score_board.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/victory_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  static const int gridSize = 28; // 28×28网格

  @override
  void initState() {
    super.initState();
    // 设置全屏模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // 恢复系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isDarkMode = gameProvider.isDarkMode;
        final gameGridSize = gameProvider.gridSize;
        
        // 计算单元格大小，确保适应屏幕
        final screenSize = MediaQuery.of(context).size;
        final cellSize = (screenSize.width < screenSize.height 
            ? screenSize.width 
            : screenSize.height) / gridSize;
        
        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          body: RawKeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKey: _handleKeyEvent,
            child: SafeArea(
              child: Center(
                child: SizedBox(
                  width: cellSize * gridSize,
                  height: cellSize * gridSize,
                  child: CustomPaint(
                    painter: GridPainter(
                      gridSize: gridSize,
                      cellSize: cellSize,
                      isDarkMode: isDarkMode,
                    ),
                    child: _buildGridContent(gameProvider, cellSize, gameGridSize),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          gameProvider.move(Direction.up);
          break;
        case LogicalKeyboardKey.arrowDown:
          gameProvider.move(Direction.down);
          break;
        case LogicalKeyboardKey.arrowLeft:
          gameProvider.move(Direction.left);
          break;
        case LogicalKeyboardKey.arrowRight:
          gameProvider.move(Direction.right);
          break;
      }
    }
  }

  Widget _buildGridContent(GameProvider gameProvider, double cellSize, int gameGridSize) {
    final isDarkMode = gameProvider.isDarkMode;
    
    // 计算游戏棋盘在28×28网格中的位置（居中）
    final startRow = (gridSize - gameGridSize) ~/ 2;
    final startCol = (gridSize - gameGridSize) ~/ 2;
    
    return Stack(
      children: [
        // 游戏棋盘
        Positioned(
          left: startCol * cellSize,
          top: startRow * cellSize,
          child: SizedBox(
            width: gameGridSize * cellSize,
            height: gameGridSize * cellSize,
            child: GameBoard(
              onSwipe: (direction) {
                gameProvider.move(direction);
              },
            ),
          ),
        ),
        
        // 标题 - 左上角第一行
        Positioned(
          left: cellSize,
          top: cellSize,
          child: GridCell(
            cellSize: cellSize,
            isDarkMode: isDarkMode,
            child: Text(
              '道（Tao）',
              style: TextStyle(
                fontSize: cellSize * 0.6,
                fontWeight: FontWeight.w100,
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'OPPOSans',
              ),
            ),
          ),
        ),
        
        // 分数 - 右上角第一行
        Positioned(
          left: (gridSize - 8) * cellSize,
          top: cellSize,
          child: SizedBox(
            width: 7 * cellSize,
            height: cellSize,
            child: _buildScoreDisplay(gameProvider, cellSize),
          ),
        ),
        
        // 设置按钮 - 右上角第一行
        Positioned(
          left: (gridSize - 1) * cellSize,
          top: cellSize,
          child: GridCell(
            cellSize: cellSize,
            isDarkMode: isDarkMode,
            child: IconButton(
              onPressed: () => _showSettingsDialog(gameProvider),
              icon: Icon(
                Icons.settings,
                size: cellSize * 0.5,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        
        // 重新开始按钮 - 左下角最后一行
        Positioned(
          left: cellSize,
          top: (gridSize - 1) * cellSize,
          child: GridCell(
            cellSize: cellSize,
            isDarkMode: isDarkMode,
            child: IconButton(
              onPressed: () => _showRestartDialog(gameProvider),
              icon: Icon(
                Icons.refresh,
                size: cellSize * 0.5,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        
        // 新游戏按钮 - 右下角最后一行
        Positioned(
          left: (gridSize - 1) * cellSize,
          top: (gridSize - 1) * cellSize,
          child: GridCell(
            cellSize: cellSize,
            isDarkMode: isDarkMode,
            child: IconButton(
              onPressed: () => _showRestartDialog(gameProvider),
              icon: Icon(
                Icons.play_arrow,
                size: cellSize * 0.5,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(GameProvider gameProvider, double cellSize) {
    final isDarkMode = gameProvider.isDarkMode;
    
    return Row(
      children: [
        // 当前分数
        Expanded(
          child: GridCell(
            cellSize: cellSize,
            isDarkMode: isDarkMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '分数',
                  style: TextStyle(
                    fontSize: cellSize * 0.2,
                    fontWeight: FontWeight.w100,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontFamily: 'OPPOSans',
                  ),
                ),
                Text(
                  gameProvider.score.toString(),
                  style: TextStyle(
                    fontSize: cellSize * 0.3,
                    fontWeight: FontWeight.w100,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'OPPOSans',
                  ),
                ),
              ],
            ),
          ),
        ),
        // 最高分数
        Expanded(
          child: GridCell(
            cellSize: cellSize,
            isDarkMode: isDarkMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '最高',
                  style: TextStyle(
                    fontSize: cellSize * 0.2,
                    fontWeight: FontWeight.w100,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontFamily: 'OPPOSans',
                  ),
                ),
                Text(
                  gameProvider.bestScore.toString(),
                  style: TextStyle(
                    fontSize: cellSize * 0.3,
                    fontWeight: FontWeight.w100,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'OPPOSans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog(GameProvider gameProvider) {
    final isDarkMode = gameProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: Text(
          '设置',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'OPPOSans',
            fontWeight: FontWeight.w100,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '网格尺寸',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontFamily: 'OPPOSans',
                fontWeight: FontWeight.w100,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGridSizeButton(gameProvider, 4, '4×4', '专家'),
                _buildGridSizeButton(gameProvider, 8, '8×8', '困难'),
                _buildGridSizeButton(gameProvider, 16, '16×16', '中等'),
                _buildGridSizeButton(gameProvider, 24, '24×24', '简单'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '深色模式',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontFamily: 'OPPOSans',
                    fontWeight: FontWeight.w100,
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    gameProvider.toggleTheme();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '关闭',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'OPPOSans',
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSizeButton(GameProvider gameProvider, int size, String label, String difficulty) {
    final isDarkMode = gameProvider.isDarkMode;
    final isSelected = gameProvider.gridSize == size;
    
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            gameProvider.setGridSize(size);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected 
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? Colors.black : Colors.white),
            foregroundColor: isSelected 
                ? (isDarkMode ? Colors.black : Colors.white)
                : (isDarkMode ? Colors.white : Colors.black),
            side: BorderSide(
              color: isDarkMode ? Colors.white : Colors.black,
              width: 1,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            minimumSize: const Size(60, 40),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'OPPOSans',
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          difficulty,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontFamily: 'OPPOSans',
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }

  void _showRestartDialog(GameProvider gameProvider) {
    final isDarkMode = gameProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: Text(
          '重新开始',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'OPPOSans',
            fontWeight: FontWeight.w100,
          ),
        ),
        content: Text(
          '确定要重新开始游戏吗？当前进度将丢失。',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontFamily: 'OPPOSans',
            fontWeight: FontWeight.w100,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'OPPOSans',
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameProvider.restart();
            },
            child: Text(
              '确定',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'OPPOSans',
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    // 监听游戏状态变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameProvider.gameWon && !gameProvider.canContinue) {
        _showVictoryDialog();
      } else if (gameProvider.gameOver) {
        _showGameOverDialog();
      }
    });
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VictoryDialog(),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GameOverDialog(),
    );
  }
}

// 网格绘制器
class GridPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;
  final bool isDarkMode;

  GridPainter({
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

    // 绘制网格线
    for (int i = 0; i <= gridSize; i++) {
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