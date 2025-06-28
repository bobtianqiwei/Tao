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
        
        // Detect system theme and update provider
        final systemIsDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          gameProvider.setSystemTheme(systemIsDark);
        });
        
        // Calculate cell size to fit screen
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
            child: Center(
              child: SizedBox(
                width: cellSize * gridSize,
                height: cellSize * gridSize,
                child: _buildGridContent(gameProvider, cellSize, gameGridSize),
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
    
    // Calculate board position to center it
    final boardStartCol = (gridSize - gameGridSize) ~/ 2;
    final boardStartRow = (gridSize - gameGridSize) ~/ 2;
    
    return Stack(
      children: [
        // Game board - centered
        Positioned(
          left: boardStartCol * cellSize,
          top: boardStartRow * cellSize,
          child: GameBoard(
            onSwipe: (direction) => gameProvider.move(direction),
          ),
        ),
        
        // Title - top left corner, centered in cell
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: cellSize,
            height: cellSize,
            child: Center(
              child: Text(
                '道',
                style: TextStyle(
                  fontSize: cellSize * 0.9,
                  fontWeight: FontWeight.w100,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'OPPOSans',
                ),
              ),
            ),
          ),
        ),
        
        // Score, Best Score, Settings - top right row (7 cells)
        Positioned(
          right: 0,
          top: 0,
          child: Row(
            children: [
              // Score label
              Container(
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Text(
                    gameProvider.scoreText,
                    style: TextStyle(
                      fontSize: cellSize * 0.3,
                      fontWeight: FontWeight.w100,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontFamily: 'OPPOSans',
                    ),
                  ),
                ),
              ),
              // Score value
              Container(
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Text(
                    gameProvider.score.toString(),
                    style: TextStyle(
                      fontSize: cellSize * 0.4,
                      fontWeight: FontWeight.w100,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'OPPOSans',
                    ),
                  ),
                ),
              ),
              // Empty cell
              Container(
                width: cellSize,
                height: cellSize,
              ),
              // Best score label
              Container(
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Text(
                    gameProvider.bestScoreText,
                    style: TextStyle(
                      fontSize: cellSize * 0.3,
                      fontWeight: FontWeight.w100,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontFamily: 'OPPOSans',
                    ),
                  ),
                ),
              ),
              // Best score value
              Container(
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Text(
                    gameProvider.bestScore.toString(),
                    style: TextStyle(
                      fontSize: cellSize * 0.4,
                      fontWeight: FontWeight.w100,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'OPPOSans',
                    ),
                  ),
                ),
              ),
              // Empty cell
              Container(
                width: cellSize,
                height: cellSize,
              ),
              // Settings button
              Container(
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSettingsDialog(gameProvider),
                      child: Container(
                        width: cellSize * 0.8,
                        height: cellSize * 0.8,
                        child: Icon(
                          Icons.settings,
                          size: cellSize * 0.5,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Restart and Auto Play buttons - bottom left row
        Positioned(
          left: 0,
          bottom: 0,
          child: Row(
            children: [
              // Restart button
              Container(
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showRestartDialog(gameProvider),
                      child: Container(
                        width: cellSize * 0.8,
                        height: cellSize * 0.8,
                        child: Icon(
                          Icons.refresh,
                          size: cellSize * 0.5,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Auto play button
              Container(
                width: cellSize,
                height: cellSize,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => gameProvider.toggleAutoPlay(),
                      child: Container(
                        width: cellSize * 0.8,
                        height: cellSize * 0.8,
                        child: Icon(
                          gameProvider.isAutoPlaying ? Icons.pause : Icons.play_arrow,
                          size: cellSize * 0.5,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Language toggle - bottom right corner
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: cellSize,
            height: cellSize,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => gameProvider.toggleLanguage(),
                  child: Container(
                    width: cellSize * 0.8,
                    height: cellSize * 0.8,
                    child: Center(
                      child: Text(
                        gameProvider.isEnglish ? '中' : 'Eng',
                        style: TextStyle(
                          fontSize: cellSize * 0.4,
                          fontWeight: FontWeight.w100,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'OPPOSans',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
          gameProvider.settingsText,
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
              gameProvider.gridSizeText,
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
                _buildGridSizeButton(gameProvider, 4, '4×4', gameProvider.expertText),
                _buildGridSizeButton(gameProvider, 8, '8×8', gameProvider.hardText),
                _buildGridSizeButton(gameProvider, 16, '16×16', gameProvider.mediumText),
                _buildGridSizeButton(gameProvider, 24, '24×24', gameProvider.easyText),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameProvider.darkModeText,
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
              gameProvider.closeText,
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              gameProvider.setGridSize(size);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? Colors.grey[900] : Colors.grey[100]),
                border: Border.all(
                  color: isDarkMode ? Colors.white : Colors.black,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected 
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : (isDarkMode ? Colors.white : Colors.black),
                    fontFamily: 'OPPOSans',
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
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
          gameProvider.restartText,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'OPPOSans',
            fontWeight: FontWeight.w100,
          ),
        ),
        content: Text(
          gameProvider.restartConfirmText,
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
              gameProvider.cancelText,
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
              gameProvider.confirmText,
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

    // 绘制网格线，延伸到屏幕边缘
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