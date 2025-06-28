import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tile.dart';
import '../models/character.dart';

enum Direction { up, down, left, right }

class GameProvider extends ChangeNotifier {
  static const int maxScore = 999999;
  static const int totalGridSize = 28; // 28×28 grid system
  
  List<List<Tile>> _board = [];
  int _score = 0;
  int _bestScore = 0;
  int _gridSize = 4;
  bool _isDarkMode = false;
  bool _isEnglish = false;
  bool _gameOver = false;
  bool _gameWon = false;
  bool _canContinue = false;
  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;
  bool _hasManualThemeSetting = false;

  // Getters
  List<List<Tile>> get board => _board;
  int get score => _score;
  int get bestScore => _bestScore;
  int get gridSize => _gridSize;
  bool get isDarkMode => _isDarkMode;
  bool get isEnglish => _isEnglish;
  bool get gameOver => _gameOver;
  bool get gameWon => _gameWon;
  bool get canContinue => _canContinue;
  bool get isAutoPlaying => _isAutoPlaying;

  GameProvider() {
    _loadGame();
  }

  // 设置网格尺寸
  void setGridSize(int size) {
    if (size != _gridSize) {
      _gridSize = size;
      initGame();
      _saveGame();
    }
  }

  // Toggle language
  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    _saveGame();
    notifyListeners();
  }

  // Toggle theme (manual override)
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _hasManualThemeSetting = true;
    _saveGame();
    notifyListeners();
  }

  // Initialize game with system theme
  void initGame() {
    _board = List.generate(_gridSize, (row) {
      return List.generate(_gridSize, (col) {
        return Tile(row: row, col: col);
      });
    });
    
    // Auto-detect system theme if not manually set
    if (!_hasManualThemeSetting) {
      _isDarkMode = _getSystemTheme();
    }
    
    _addRandomTile();
    _addRandomTile();
    _score = 0;
    _gameOver = false;
    _gameWon = false;
    _canContinue = false;
    notifyListeners();
  }

  // Get system theme preference
  bool _getSystemTheme() {
    // This will be set by the UI layer based on MediaQuery
    return false; // Default to light mode
  }

  // Set system theme detection
  void setSystemTheme(bool isDark) {
    if (!_hasManualThemeSetting) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }

  // 添加随机方块
  void _addRandomTile() {
    final emptyTiles = <Tile>[];
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col].isEmpty) {
          emptyTiles.add(_board[row][col]);
        }
      }
    }

    if (emptyTiles.isNotEmpty) {
      final random = Random();
      final randomTile = emptyTiles[random.nextInt(emptyTiles.length)];
      final initialCharacters = Character.getInitialCharacters();
      final randomCharacter = initialCharacters[random.nextInt(initialCharacters.length)];
      
      _board[randomTile.row][randomTile.col] = randomTile.copyWith(
        character: randomCharacter,
        isNew: true,
      );
    }
  }

  // Move in specified direction
  bool move(Direction direction) {
    if (_gameOver && !_canContinue) return false;
    
    bool moved = false;
    switch (direction) {
      case Direction.up:
        moved = _moveUp();
        break;
      case Direction.down:
        moved = _moveDown();
        break;
      case Direction.left:
        moved = _moveLeft();
        break;
      case Direction.right:
        moved = _moveRight();
        break;
    }
    
    if (moved) {
      _addRandomTile();
      _checkGameState();
      _saveGame();
      notifyListeners();
    }
    
    return moved;
  }

  // 向上移动
  bool _moveUp() {
    bool moved = false;
    for (int col = 0; col < _gridSize; col++) {
      final column = <Tile>[];
      for (int row = 0; row < _gridSize; row++) {
        if (!_board[row][col].isEmpty) {
          column.add(_board[row][col]);
        }
      }
      
      final mergedColumn = _mergeTiles(column);
      for (int row = 0; row < _gridSize; row++) {
        final newTile = row < mergedColumn.length 
            ? mergedColumn[row].copyWith(row: row, col: col)
            : Tile(row: row, col: col);
        
        if (_board[row][col] != newTile) {
          moved = true;
        }
        _board[row][col] = newTile;
      }
    }
    return moved;
  }

  // Move down
  bool _moveDown() {
    bool moved = false;
    for (int col = 0; col < _gridSize; col++) {
      // Create a new column with merged tiles
      final newColumn = List<Tile>.filled(_gridSize, Tile(row: 0, col: col));
      int newIndex = _gridSize - 1;
      
      // Process tiles from bottom to top
      for (int row = _gridSize - 1; row >= 0; row--) {
        if (!_board[row][col].isEmpty) {
          newColumn[newIndex] = _board[row][col].copyWith(row: newIndex, col: col);
          newIndex--;
        }
      }
      
      // Merge adjacent tiles
      for (int i = _gridSize - 1; i > 0; i--) {
        if (!newColumn[i].isEmpty && 
            !newColumn[i-1].isEmpty && 
            newColumn[i].canMergeWith(newColumn[i-1])) {
          final mergedTile = newColumn[i].mergeWith(newColumn[i-1]);
          newColumn[i] = mergedTile.copyWith(row: i, col: col);
          newColumn[i-1] = Tile(row: i-1, col: col);
          _score += _calculateMergeScore(mergedTile);
        }
      }
      
      // Update board
      for (int row = 0; row < _gridSize; row++) {
        if (_board[row][col] != newColumn[row]) {
          moved = true;
        }
        _board[row][col] = newColumn[row];
      }
    }
    return moved;
  }

  // Move left
  bool _moveLeft() {
    bool moved = false;
    for (int row = 0; row < _gridSize; row++) {
      // Create a new row with merged tiles
      final newRow = List<Tile>.filled(_gridSize, Tile(row: row, col: 0));
      int newIndex = 0;
      
      // Process tiles from left to right
      for (int col = 0; col < _gridSize; col++) {
        if (!_board[row][col].isEmpty) {
          newRow[newIndex] = _board[row][col].copyWith(row: row, col: newIndex);
          newIndex++;
        }
      }
      
      // Merge adjacent tiles
      for (int i = 0; i < newIndex - 1; i++) {
        if (!newRow[i].isEmpty && 
            !newRow[i+1].isEmpty && 
            newRow[i].canMergeWith(newRow[i+1])) {
          final mergedTile = newRow[i].mergeWith(newRow[i+1]);
          newRow[i] = mergedTile.copyWith(row: row, col: i);
          newRow[i+1] = Tile(row: row, col: i+1);
          _score += _calculateMergeScore(mergedTile);
        }
      }
      
      // Update board
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col] != newRow[col]) {
          moved = true;
        }
        _board[row][col] = newRow[col];
      }
    }
    return moved;
  }

  // Move right
  bool _moveRight() {
    bool moved = false;
    for (int row = 0; row < _gridSize; row++) {
      // Create a new row with merged tiles
      final newRow = List<Tile>.filled(_gridSize, Tile(row: row, col: 0));
      int newIndex = _gridSize - 1;
      
      // Process tiles from right to left
      for (int col = _gridSize - 1; col >= 0; col--) {
        if (!_board[row][col].isEmpty) {
          newRow[newIndex] = _board[row][col].copyWith(row: row, col: newIndex);
          newIndex--;
        }
      }
      
      // Merge adjacent tiles
      for (int i = _gridSize - 1; i > 0; i--) {
        if (!newRow[i].isEmpty && 
            !newRow[i-1].isEmpty && 
            newRow[i].canMergeWith(newRow[i-1])) {
          final mergedTile = newRow[i].mergeWith(newRow[i-1]);
          newRow[i] = mergedTile.copyWith(row: row, col: i);
          newRow[i-1] = Tile(row: row, col: i-1);
          _score += _calculateMergeScore(mergedTile);
        }
      }
      
      // Update board
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col] != newRow[col]) {
          moved = true;
        }
        _board[row][col] = newRow[col];
      }
    }
    return moved;
  }

  // 合并方块
  List<Tile> _mergeTiles(List<Tile> tiles) {
    if (tiles.isEmpty) return [];
    
    final result = <Tile>[];
    int i = 0;
    
    while (i < tiles.length) {
      if (i + 1 < tiles.length && tiles[i].canMergeWith(tiles[i + 1])) {
        final mergedTile = tiles[i].mergeWith(tiles[i + 1]);
        result.add(mergedTile);
        _score += _calculateMergeScore(mergedTile);
        i += 2;
      } else {
        result.add(tiles[i].copyWith(isNew: false, isMerged: false));
        i++;
      }
    }
    
    return result;
  }

  // 计算合并得分
  int _calculateMergeScore(Tile tile) {
    if (tile.character == null) return 0;
    
    final baseScore = tile.character!.level * 10;
    if (tile.character!.elementType == ElementType.dao) {
      return maxScore; // 合成道获得最高分
    }
    return baseScore;
  }

  // 检查游戏状态
  void _checkGameState() {
    // 检查是否获胜（合成出道）
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col].character?.elementType == ElementType.dao) {
          _gameWon = true;
          _canContinue = true;
          if (_score > _bestScore) {
            _bestScore = _score;
          }
          return;
        }
      }
    }

    // 检查是否游戏结束
    if (!_canMove()) {
      _gameOver = true;
    }

    // 更新最高分
    if (_score > _bestScore) {
      _bestScore = _score;
    }
  }

  // 检查是否可以移动
  bool _canMove() {
    // 检查是否有空格
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col].isEmpty) return true;
      }
    }

    // 检查是否可以合并
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final currentTile = _board[row][col];
        if (currentTile.isEmpty) continue;

        // 检查右边
        if (col + 1 < _gridSize && currentTile.canMergeWith(_board[row][col + 1])) {
          return true;
        }
        // 检查下边
        if (row + 1 < _gridSize && currentTile.canMergeWith(_board[row + 1][col])) {
          return true;
        }
      }
    }

    return false;
  }

  // 复制棋盘
  List<List<Tile>> _copyBoard() {
    return _board.map((row) => row.map((tile) => tile.copyWith()).toList()).toList();
  }

  // 重新开始游戏
  void restart() {
    initGame();
    _saveGame();
  }

  // 继续游戏（在获胜后）
  void continueGame() {
    _canContinue = true;
    notifyListeners();
  }

  // 保存游戏
  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', _bestScore);
    await prefs.setInt('gridSize', _gridSize);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isEnglish', _isEnglish);
  }

  // 加载游戏
  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt('bestScore') ?? 0;
    _gridSize = prefs.getInt('gridSize') ?? 4;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isEnglish = prefs.getBool('isEnglish') ?? false;
    initGame();
  }

  // Get localized text
  String getText(String chinese, String english) {
    return _isEnglish ? english : chinese;
  }

  // Get localized texts
  String get scoreText => getText('分数', 'Score');
  String get bestScoreText => getText('最高', 'Best');
  String get settingsText => getText('设置', 'Settings');
  String get restartText => getText('重新开始', 'Restart');
  String get cancelText => getText('取消', 'Cancel');
  String get confirmText => getText('确定', 'Confirm');
  String get gridSizeText => getText('网格尺寸', 'Grid Size');
  String get darkModeText => getText('深色模式', 'Dark Mode');
  String get closeText => getText('关闭', 'Close');
  String get expertText => getText('专家', 'Expert');
  String get hardText => getText('困难', 'Hard');
  String get mediumText => getText('中等', 'Medium');
  String get easyText => getText('简单', 'Easy');
  String get restartConfirmText => getText('确定要重新开始游戏吗？当前进度将丢失。', 'Are you sure you want to restart? Current progress will be lost.');

  // Auto play functionality
  void toggleAutoPlay() {
    if (_isAutoPlaying) {
      stopAutoPlay();
    } else {
      startAutoPlay();
    }
  }

  void startAutoPlay() {
    if (_gameOver && !_canContinue) return;
    
    _isAutoPlaying = true;
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isAutoPlaying || _gameOver) {
        stopAutoPlay();
        return;
      }
      
      // Random AI: try moves in random order
      final moves = [Direction.right, Direction.down, Direction.left, Direction.up];
      moves.shuffle();
      bool moved = false;
      
      for (final direction in moves) {
        if (move(direction)) {
          moved = true;
          break;
        }
      }
      
      if (!moved) {
        stopAutoPlay();
      }
    });
    notifyListeners();
  }

  void stopAutoPlay() {
    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoPlay();
    super.dispose();
  }
} 