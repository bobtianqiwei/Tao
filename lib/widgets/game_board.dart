import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/tile.dart';
import 'tile_widget.dart';

class GameBoard extends StatefulWidget {
  final Function(Direction) onSwipe;

  const GameBoard({
    super.key,
    required this.onSwipe,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Offset? _startPosition;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            width: 320,
            height: 320,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFBBADA0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                final row = index ~/ 4;
                final col = index % 4;
                final tile = gameProvider.board[row][col];
                return TileWidget(tile: tile);
              },
            ),
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // 可以在这里添加实时反馈
  }

  void _onPanEnd(DragEndDetails details) {
    if (_startPosition == null) return;

    final endPosition = details.globalPosition;
    final deltaX = endPosition.dx - _startPosition!.dx;
    final deltaY = endPosition.dy - _startPosition!.dy;
    final minSwipeDistance = 50.0;

    if (deltaX.abs() > deltaY.abs()) {
      // 水平滑动
      if (deltaX.abs() > minSwipeDistance) {
        if (deltaX > 0) {
          widget.onSwipe(Direction.right);
        } else {
          widget.onSwipe(Direction.left);
        }
      }
    } else {
      // 垂直滑动
      if (deltaY.abs() > minSwipeDistance) {
        if (deltaY > 0) {
          widget.onSwipe(Direction.down);
        } else {
          widget.onSwipe(Direction.up);
        }
      }
    }

    _startPosition = null;
  }
} 