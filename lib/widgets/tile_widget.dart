import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tile.dart';

class TileWidget extends StatefulWidget {
  final Tile tile;

  const TileWidget({
    super.key,
    required this.tile,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: widget.tile.backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: widget.tile.isEmpty
            ? null
            : _buildCharacterContent(),
      ),
    ).animate()
      .scale(
        begin: widget.tile.isNew ? 0.0 : 1.0,
        end: 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
      )
      .then()
      .animate(
        onPlay: (controller) {
          if (widget.tile.isMerged) {
            controller.repeat(reverse: true, count: 2);
          }
        },
      )
      .scale(
        begin: 1.0,
        end: 1.1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
  }

  Widget _buildCharacterContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 汉字
        Text(
          widget.tile.displayText,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.bold,
            color: widget.tile.textColor,
            fontFamily: 'NotoSansSC',
          ),
        ),
        
        // 拼音（可选显示）
        if (widget.tile.character != null && widget.tile.character!.level > 1)
          Text(
            widget.tile.character!.pinyin,
            style: TextStyle(
              fontSize: 10,
              color: widget.tile.textColor.withOpacity(0.8),
            ),
          ),
      ],
    );
  }

  double _getFontSize() {
    if (widget.tile.character == null) return 24;
    
    final character = widget.tile.character!.character;
    if (character.length == 1) {
      return 32;
    } else if (character.length == 2) {
      return 28;
    } else {
      return 24;
    }
  }
} 