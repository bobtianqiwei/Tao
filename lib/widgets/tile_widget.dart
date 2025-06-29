import 'package:flutter/material.dart';
import '../models/tile.dart';

class TileWidget extends StatefulWidget {
  final Tile tile;
  final double size;
  final bool showGlow;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.showGlow = false,
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
    final isDao = widget.tile.character?.elementType.toString() == 'ElementType.dao';
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        Widget tileContent = Transform.scale(
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
                    fontSize: widget.size * 0.9,
                    fontWeight: FontWeight.w100,
                    color: widget.tile.textColor,
                    fontFamily: 'OPPOSans',
                  ),
                ),
              ),
            ),
          ),
        );

        if (isDao && widget.showGlow) {
          tileContent = _GlowingTile(
            child: tileContent,
          );
        }
        return tileContent;
      },
    );
  }
}

class _GlowingTile extends StatefulWidget {
  final Widget child;
  const _GlowingTile({required this.child});

  @override
  State<_GlowingTile> createState() => _GlowingTileState();
}

class _GlowingTileState extends State<_GlowingTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // Extended to 2 minutes
    );
    _glowAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60), // 0-60s full glow
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60), // 60-120s fade out
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // The original tile content
            widget.child,
            // Glow effect overlay positioned above everything
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(_glowAnimation.value * 0.8),
                        blurRadius: 32 * _glowAnimation.value + 8,
                        spreadRadius: 8 * _glowAnimation.value + 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 