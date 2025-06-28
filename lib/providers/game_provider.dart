import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tile.dart';
import '../models/character.dart';

class GameProvider extends ChangeNotifier {
  static const int gridSize = 4;
  static const int maxScore = 1000000;
  
  List<List<Tile>> _board = [];
  int _score = 0;
  int _bestScore = 0;
  bool _gameOver = false;
  bool _gameWon = false;
  bool _canContinue = false;

  // Getters
  List<List<Tile>> get board => _board;
  int get score => _score;
  int get bestScore => _bestScore;
  bool get gameOver => _gameOver;
  bool get gameWon => _gameWon;
  bool get canContinue => _canContinue;

  GameProvider() {
    _loadGame();
  }

  // 初始化游戏
  void initGame() {
    _board = List.generate(
      gridSize,
      (row) => List.generate(
        gridSize,
        (col) => Tile(row: row, col: col),
      ),
    );
    _score = 0;
    _gameOver = false;
    _gameWon = false;
    _canContinue = false;
    
    // 添加初始方块
    _addRandomTile();
    _addRandomTile();
    
    notifyListeners();
  }

  // 添加随机方块
  void _addRandomTile() {
    final emptyTiles = <Tile>[];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
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

  // 移动方块
  void move(Direction direction) {
    if (_gameOver && !_canContinue) return;

    final oldBoard = _copyBoard();
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
  }

  // 向上移动
  bool _moveUp() {
    bool moved = false;
    for (int col = 0; col < gridSize; col++) {
      final column = <Tile>[];
      for (int row = 0; row < gridSize; row++) {
        if (!_board[row][col].isEmpty) {
          column.add(_board[row][col]);
        }
      }
      
      final mergedColumn = _mergeTiles(column);
      for (int row = 0; row < gridSize; row++) {
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

  // 向下移动
  bool _moveDown() {
    bool moved = false;
    for (int col = 0; col < gridSize; col++) {
      final column = <Tile>[];
      for (int row = gridSize - 1; row >= 0; row--) {
        if (!_board[row][col].isEmpty) {
          column.add(_board[row][col]);
        }
      }
      
      final mergedColumn = _mergeTiles(column);
      for (int row = 0; row < gridSize; row++) {
        final newTile = row < mergedColumn.length 
            ? mergedColumn[gridSize - 1 - row].copyWith(row: row, col: col)
            : Tile(row: row, col: col);
        
        if (_board[row][col] != newTile) {
          moved = true;
        }
        _board[row][col] = newTile;
      }
    }
    return moved;
  }

  // 向左移动
  bool _moveLeft() {
    bool moved = false;
    for (int row = 0; row < gridSize; row++) {
      final rowTiles = <Tile>[];
      for (int col = 0; col < gridSize; col++) {
        if (!_board[row][col].isEmpty) {
          rowTiles.add(_board[row][col]);
        }
      }
      
      final mergedRow = _mergeTiles(rowTiles);
      for (int col = 0; col < gridSize; col++) {
        final newTile = col < mergedRow.length 
            ? mergedRow[col].copyWith(row: row, col: col)
            : Tile(row: row, col: col);
        
        if (_board[row][col] != newTile) {
          moved = true;
        }
        _board[row][col] = newTile;
      }
    }
    return moved;
  }

  // 向右移动
  bool _moveRight() {
    bool moved = false;
    for (int row = 0; row < gridSize; row++) {
      final rowTiles = <Tile>[];
      for (int col = gridSize - 1; col >= 0; col--) {
        if (!_board[row][col].isEmpty) {
          rowTiles.add(_board[row][col]);
        }
      }
      
      final mergedRow = _mergeTiles(rowTiles);
      for (int col = 0; col < gridSize; col++) {
        final newTile = col < mergedRow.length 
            ? mergedRow[gridSize - 1 - col].copyWith(row: row, col: col)
            : Tile(row: row, col: col);
        
        if (_board[row][col] != newTile) {
          moved = true;
        }
        _board[row][col] = newTile;
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
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
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
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (_board[row][col].isEmpty) return true;
      }
    }

    // 检查是否可以合并
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final currentTile = _board[row][col];
        if (currentTile.isEmpty) continue;

        // 检查右边
        if (col + 1 < gridSize && currentTile.canMergeWith(_board[row][col + 1])) {
          return true;
        }
        // 检查下边
        if (row + 1 < gridSize && currentTile.canMergeWith(_board[row + 1][col])) {
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
    // 这里可以添加更多保存逻辑
  }

  // 加载游戏
  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt('bestScore') ?? 0;
    initGame();
  }
}

enum Direction { up, down, left, right } 