import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class FullScreenConfetti extends StatefulWidget {
  final bool show;
  final Duration duration;

  const FullScreenConfetti({
    super.key,
    required this.show,
    this.duration = const Duration(seconds: 120),
  });

  @override
  State<FullScreenConfetti> createState() => _FullScreenConfettiState();
}

class _FullScreenConfettiState extends State<FullScreenConfetti> {
  late ConfettiController _controller;
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FullScreenConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !_hasPlayed) {
      print('🎊 开始播放彩带');
      _controller.play();
      _hasPlayed = true;
    } else if (!widget.show && _hasPlayed) {
      print('🛑 停止彩带');
      _controller.stop();
      _hasPlayed = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: Stack(
        children: [
          // 左上角彩带
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: pi / 4,
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.02,
              numberOfParticles: 60,
              gravity: 0.01,
              colors: const [Colors.pink, Colors.orange, Colors.teal, Colors.purple],
            ),
          ),
          // 右上角彩带
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: 3 * pi / 4,
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.02,
              numberOfParticles: 60,
              gravity: 0.01,
              colors: const [Colors.indigo, Colors.cyan, Colors.lime, Colors.blue],
            ),
          ),
          // 左下角彩带
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: -pi / 4,
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.02,
              numberOfParticles: 60,
              gravity: 0.01,
              colors: const [Colors.green, Colors.red, Colors.amber, Colors.yellow],
            ),
          ),
          // 右下角彩带
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: -3 * pi / 4,
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.02,
              numberOfParticles: 60,
              gravity: 0.01,
              colors: const [Colors.orange, Colors.pink, Colors.teal, Colors.indigo],
            ),
          ),
        ],
      ),
    );
  }
} 