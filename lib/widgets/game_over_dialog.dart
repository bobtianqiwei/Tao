import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isDarkMode = gameProvider.isDarkMode;
        
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: Text(
            '游戏结束',
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
                '没有更多移动可能了',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontFamily: 'OPPOSans',
                  fontWeight: FontWeight.w100,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '最终得分：${gameProvider.score}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'OPPOSans',
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameProvider.restart();
              },
              child: Text(
                '重新开始',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'OPPOSans',
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 