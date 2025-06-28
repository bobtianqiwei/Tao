import 'package:flutter/material.dart';
import '../models/tile.dart';

class TileWidget extends StatefulWidget {
  final Tile tile;
  final double size;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    if (widget.tile.isNew) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.tile.isNew && !oldWidget.tile.isNew) {
      _animationController.forward();
    } else if (widget.tile.isMerged && !oldWidget.tile.isMerged) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              color: isDarkMode ? Colors.black : Colors.white,
              child: Center(
                child: Text(
                  widget.tile.displayText,
                  style: TextStyle(
                    fontSize: widget.size * 0.8,
                    fontWeight: FontWeight.w100,
                    color: widget.tile.textColor,
                    fontFamily: 'OPPOSans',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 