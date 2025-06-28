import 'package:flutter/material.dart';

enum ElementType { wood, fire, earth, metal, water, dao }

class Character {
  final String character;
  final ElementType elementType;
  final int level;
  final String pinyin;
  final String meaning;

  const Character({
    required this.character,
    required this.elementType,
    required this.level,
    required this.pinyin,
    required this.meaning,
  });

  // 获取下一个等级的汉字
  Character? getNextLevel() {
    switch (elementType) {
      case ElementType.wood:
        switch (level) {
          case 1: return Character.wood2;
          case 2: return Character.wood3;
          case 3: return Character.fire1; // 木生火
        }
        break;
      case ElementType.fire:
        switch (level) {
          case 1: return Character.fire2;
          case 2: return Character.fire3;
          case 3: return Character.earth1; // 火生土
        }
        break;
      case ElementType.earth:
        switch (level) {
          case 1: return Character.earth2;
          case 2: return Character.earth3;
          case 3: return Character.metal1; // 土生金
        }
        break;
      case ElementType.metal:
        switch (level) {
          case 1: return Character.metal2;
          case 2: return Character.metal3;
          case 3: return Character.water1; // 金生水
        }
        break;
      case ElementType.water:
        switch (level) {
          case 1: return Character.water2;
          case 2: return Character.water3;
          case 3: return Character.wood1; // 水生木
        }
        break;
      case ElementType.dao:
        return null; // 道是终极目标
    }
    return null;
  }

  // 获取颜色
  Color getColor() {
    switch (elementType) {
      case ElementType.wood:
        return Colors.green;
      case ElementType.fire:
        return Colors.red;
      case ElementType.earth:
        return Colors.brown;
      case ElementType.metal:
        return Colors.amber;
      case ElementType.water:
        return Colors.blue;
      case ElementType.dao:
        return Colors.purple;
    }
  }

  // 预定义的汉字常量
  static const Character wood1 = Character(
    character: '木',
    elementType: ElementType.wood,
    level: 1,
    pinyin: 'mù',
    meaning: '树木',
  );
  static const Character wood2 = Character(
    character: '林',
    elementType: ElementType.wood,
    level: 2,
    pinyin: 'lín',
    meaning: '树林',
  );
  static const Character wood3 = Character(
    character: '森',
    elementType: ElementType.wood,
    level: 3,
    pinyin: 'sēn',
    meaning: '森林',
  );

  static const Character fire1 = Character(
    character: '火',
    elementType: ElementType.fire,
    level: 1,
    pinyin: 'huǒ',
    meaning: '火焰',
  );
  static const Character fire2 = Character(
    character: '炎',
    elementType: ElementType.fire,
    level: 2,
    pinyin: 'yán',
    meaning: '炎热',
  );
  static const Character fire3 = Character(
    character: '燚',
    elementType: ElementType.fire,
    level: 3,
    pinyin: 'yì',
    meaning: '火势旺盛',
  );

  static const Character earth1 = Character(
    character: '土',
    elementType: ElementType.earth,
    level: 1,
    pinyin: 'tǔ',
    meaning: '土地',
  );
  static const Character earth2 = Character(
    character: '圭',
    elementType: ElementType.earth,
    level: 2,
    pinyin: 'guī',
    meaning: '玉器',
  );
  static const Character earth3 = Character(
    character: '垚',
    elementType: ElementType.earth,
    level: 3,
    pinyin: 'yáo',
    meaning: '山高',
  );

  static const Character metal1 = Character(
    character: '金',
    elementType: ElementType.metal,
    level: 1,
    pinyin: 'jīn',
    meaning: '金属',
  );
  static const Character metal2 = Character(
    character: '鑫',
    elementType: ElementType.metal,
    level: 2,
    pinyin: 'xīn',
    meaning: '财富兴盛',
  );
  static const Character metal3 = Character(
    character: '鑾',
    elementType: ElementType.metal,
    level: 3,
    pinyin: 'luán',
    meaning: '铃铛',
  );

  static const Character water1 = Character(
    character: '水',
    elementType: ElementType.water,
    level: 1,
    pinyin: 'shuǐ',
    meaning: '水',
  );
  static const Character water2 = Character(
    character: '沝',
    elementType: ElementType.water,
    level: 2,
    pinyin: 'zhuǐ',
    meaning: '水',
  );
  static const Character water3 = Character(
    character: '淼',
    elementType: ElementType.water,
    level: 3,
    pinyin: 'miǎo',
    meaning: '水多',
  );

  static const Character dao = Character(
    character: '道',
    elementType: ElementType.dao,
    level: 0,
    pinyin: 'dào',
    meaning: '宇宙本源',
  );

  // 获取所有初始汉字
  static List<Character> getInitialCharacters() {
    return [wood1, fire1, earth1, metal1, water1];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Character &&
        other.character == character &&
        other.elementType == elementType &&
        other.level == level;
  }

  @override
  int get hashCode {
    return character.hashCode ^ elementType.hashCode ^ level.hashCode;
  }
} 