import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isDarkMode = gameProvider.isDarkMode;
        
        return Row(
          children: [
            // 当前分数
            Expanded(
              child: _buildScoreCard(
                '分数',
                gameProvider.score.toString(),
                isDarkMode,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 最高分数
            Expanded(
              child: _buildScoreCard(
                '最高',
                gameProvider.bestScore.toString(),
                isDarkMode,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreCard(String label, String value, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        border: Border.all(
          color: isDarkMode ? Colors.white : Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontFamily: 'OPPOSans',
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'OPPOSans',
            ),
          ),
        ],
      ),
    );
  }
} 