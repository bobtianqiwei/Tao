import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/victory_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return Column(
              children: [
                // 顶部栏
                _buildHeader(gameProvider),
                
                // 分数板
                const ScoreBoard(),
                
                // 游戏说明
                _buildInstructions(),
                
                // 游戏棋盘
                Expanded(
                  child: Center(
                    child: GameBoard(
                      onSwipe: (direction) {
                        gameProvider.move(direction);
                      },
                    ),
                  ),
                ),
                
                // 底部按钮
                _buildBottomButtons(gameProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标题
          const Text(
            '五行2048',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF776E65),
            ),
          ),
          
          // 重新开始按钮
          IconButton(
            onPressed: () {
              _showRestartDialog(gameProvider);
            },
            icon: const Icon(
              Icons.refresh,
              size: 28,
              color: Color(0xFF776E65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE4DA),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Text(
        '滑动合并相同汉字，遵循五行相生：木→火→土→金→水→木，最终合成「道」',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF776E65),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomButtons(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 撤销按钮（可以后续实现）
          ElevatedButton.icon(
            onPressed: null, // 暂时禁用
            icon: const Icon(Icons.undo),
            label: const Text('撤销'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F7A66),
              foregroundColor: Colors.white,
            ),
          ),
          
          // 新游戏按钮
          ElevatedButton.icon(
            onPressed: () {
              _showRestartDialog(gameProvider);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('新游戏'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F7A66),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新开始'),
        content: const Text('确定要重新开始游戏吗？当前进度将丢失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameProvider.restart();
            },
            child: const Text('确定'),
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