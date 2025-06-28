import 'package:flutter/material.dart';

class GridCell extends StatelessWidget {
  final double cellSize;
  final bool isDarkMode;
  final Widget child;

  const GridCell({
    super.key,
    required this.cellSize,
    required this.isDarkMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: child,
    );
  }
} 