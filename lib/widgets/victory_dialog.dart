import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/game_provider.dart';

class VictoryDialog extends StatefulWidget {
  const VictoryDialog({super.key});

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final isDarkMode = gameProvider.isDarkMode;
            
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: Text(
                '恭喜！',
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
                    '你成功合成了「道」！',
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
                    gameProvider.continueGame();
                  },
                  child: Text(
                    '继续游戏',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
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
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.05,
            colors: const [Colors.black, Colors.grey],
          ),
        ),
      ],
    );
  }
} 