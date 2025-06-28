import 'package:flutter/material.dart';
import 'character.dart';

class Tile {
  Character? character;
  bool isNew;
  bool isMerged;
  int row;
  int col;

  Tile({
    this.character,
    this.isNew = false,
    this.isMerged = false,
    required this.row,
    required this.col,
  });

  // 复制方块
  Tile copyWith({
    Character? character,
    bool? isNew,
    bool? isMerged,
    int? row,
    int? col,
  }) {
    return Tile(
      character: character ?? this.character,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }

  // 检查是否可以合并
  bool canMergeWith(Tile other) {
    if (character == null || other.character == null) return false;
    return character == other.character;
  }

  // 合并方块
  Tile mergeWith(Tile other) {
    if (!canMergeWith(other)) {
      throw Exception('Cannot merge incompatible tiles');
    }
    
    final nextLevel = character!.getNextLevel();
    return Tile(
      character: nextLevel,
      isNew: true,
      isMerged: true,
      row: row,
      col: col,
    );
  }

  // 检查是否为空
  bool get isEmpty => character == null;

  // 获取显示文本
  String get displayText => character?.character ?? '';

  // 获取背景颜色 - 根据主题模式返回
  Color get backgroundColor => Colors.white; // 将在widget中根据主题动态设置

  // 获取文字颜色
  Color get textColor {
    if (character == null) return Colors.transparent;
    return character!.getColor();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tile &&
        other.character == character &&
        other.row == row &&
        other.col == col;
  }

  @override
  int get hashCode {
    return character.hashCode ^ row.hashCode ^ col.hashCode;
  }
} 