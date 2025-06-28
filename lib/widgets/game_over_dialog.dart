import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '游戏结束',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF776E65),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '没有更多移动可能了',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF776E65),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return Text(
                  '最终得分：${gameProvider.score}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8F7A66),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    final gameProvider = Provider.of<GameProvider>(context, listen: false);
                    gameProvider.restart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F7A66),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('重新开始'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('退出'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 