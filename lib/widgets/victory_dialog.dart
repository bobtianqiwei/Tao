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
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  '恭喜！',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF776E65),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '你成功合成了「道」！',
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
                        gameProvider.continueGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8F7A66),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('继续游戏'),
                    ),
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
                  ],
                ),
              ],
            ),
          ),
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
          ),
        ),
      ],
    );
  }
} 