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
      color: isDarkMode ? Colors.black : Colors.white,
      child: Center(child: child),
    );
  }
} 