import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tile.dart';
import '../models/character.dart';

enum Direction { up, down, left, right }
enum AutoPlayMode { random, ml }
enum MLModel { 
  heuristic,    // 启发式算法
  corner,       // 角落策略
  snake,        // 蛇形路径
  edge,         // 边缘策略
  center,       // 中心策略
  random,       // 随机策略
  greedy,       // 贪心策略
  conservative, // 保守策略
  advanced      // 高级算法
}

class GameProvider extends ChangeNotifier {
  static const int maxScore = 999999;
  static const int totalGridSize = 28; // 28×28 grid system
  
  List<List<Tile>> _board = [];
  int _score = 0;
  int _bestScore = 0;
  int _gridSize = 4;
  bool _isDarkMode = false;
  bool _isEnglish = true;
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
    bool victoryDetected = false; // 添加胜利检测标志
    
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
          
          // 立即检查是否生成了"道"
          if (mergedTile.character?.elementType == ElementType.dao) {
            print('🎉 向下移动中检测到道字！位置: ($i, $col)');
            print('🎉 道字信息: ${mergedTile.character?.character}, ${mergedTile.character?.elementType}');
            _gameWon = true;
            _canContinue = false;
            if (_score > _bestScore) {
              _bestScore = _score;
            }
            print('🎉 设置胜利状态: _gameWon=$_gameWon, _canContinue=$_canContinue');
          }
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
          
          // 立即检查是否生成了"道"
          if (mergedTile.character?.elementType == ElementType.dao) {
            print('🎉 向左移动中检测到道字！位置: ($row, $i)');
            _gameWon = true;
            _canContinue = false;
            if (_score > _bestScore) {
              _bestScore = _score;
            }
          }
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
          
          // 立即检查是否生成了"道"
          if (mergedTile.character?.elementType == ElementType.dao) {
            print('🎉 向右移动中检测到道字！位置: ($row, $i)');
            _gameWon = true;
            _canContinue = false;
            if (_score > _bestScore) {
              _bestScore = _score;
            }
          }
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
        
        // 立即检查是否生成了"道"
        if (mergedTile.character?.elementType == ElementType.dao) {
          print('🎉 向上移动中检测到道字！');
          _gameWon = true;
          _canContinue = false;
          if (_score > _bestScore) {
            _bestScore = _score;
          }
          notifyListeners();
        }
        
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
          print('🎉 检测到道字！位置: ($row, $col)'); // 调试信息
          _gameWon = true;
          _canContinue = false; // 初始设置为false，让胜利对话框显示
          if (_score > _bestScore) {
            _bestScore = _score;
          }
          notifyListeners(); // 立即通知UI更新
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
    _gameWon = false; // 重置胜利状态，允许继续游戏
    notifyListeners();
  }

  // Save game
  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', _bestScore);
    await prefs.setInt('gridSize', _gridSize);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isEnglish', _isEnglish);
    await prefs.setInt('autoPlayMode', _autoPlayMode.index);
    await prefs.setInt('selectedMLModel', _selectedMLModel.index);
  }

  // Load game
  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt('bestScore') ?? 0;
    _gridSize = prefs.getInt('gridSize') ?? 4;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isEnglish = prefs.getBool('isEnglish') ?? true;
    final autoPlayModeIndex = prefs.getInt('autoPlayMode') ?? 0;
    _autoPlayMode = AutoPlayMode.values[autoPlayModeIndex];
    final selectedMLModelIndex = prefs.getInt('selectedMLModel') ?? 0;
    _selectedMLModel = MLModel.values[selectedMLModelIndex];
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
  String get developerText => getText('开发者：Bob Tianqi Wei\ngithub.com/bobtianqiwei', 'Developer: Bob Tianqi Wei\ngithub.com/bobtianqiwei');

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
      
      // Check for victory before making next move
      if (_gameWon && !_canContinue) {
        stopAutoPlay();
        return;
      }
      
      Direction? nextMove;
      
      if (_autoPlayMode == AutoPlayMode.random) {
        // Random AI: try moves in random order
        final moves = [Direction.right, Direction.down, Direction.left, Direction.up];
        moves.shuffle();
        
        for (final direction in moves) {
          if (_canMoveInDirection(direction)) {
            nextMove = direction;
            break;
          }
        }
      } else {
        // ML AI: use machine learning to predict best move
        nextMove = _getMLMove();
      }
      
      if (nextMove != null) {
        move(nextMove);
        
        // Check for victory after each move
        if (_gameWon && !_canContinue) {
          stopAutoPlay();
          return;
        }
      } else {
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

  // Auto play modes
  AutoPlayMode _autoPlayMode = AutoPlayMode.random;
  MLModel _selectedMLModel = MLModel.heuristic;
  
  AutoPlayMode get autoPlayMode => _autoPlayMode;
  MLModel get selectedMLModel => _selectedMLModel;
  
  void setAutoPlayMode(AutoPlayMode mode) {
    _autoPlayMode = mode;
    _saveGame();
    notifyListeners();
  }
  
  void setMLModel(MLModel model) {
    _selectedMLModel = model;
    _saveGame();
    notifyListeners();
  }

  // Check if a move is possible without actually moving
  bool _canMoveInDirection(Direction direction) {
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
    
    // Restore board
    _board = oldBoard;
    return moved;
  }

  // Simple ML-based move prediction
  Direction? _getMLMove() {
    switch (_selectedMLModel) {
      case MLModel.heuristic:
        return _getHeuristicMove();
      case MLModel.corner:
        return _getCornerMove();
      case MLModel.snake:
        return _getSnakeMove();
      case MLModel.edge:
        return _getEdgeMove();
      case MLModel.center:
        return _getCenterMove();
      case MLModel.random:
        return _getRandomMove();
      case MLModel.greedy:
        return _getGreedyMove();
      case MLModel.conservative:
        return _getConservativeMove();
      case MLModel.advanced:
        return _getAdvancedMove();
    }
  }

  // Heuristic-based AI (original)
  Direction? _getHeuristicMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    // Check all possible moves
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    // Return the move with highest score
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Corner-focused AI (prefers keeping high values in corners)
  Direction? _getCornerMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateCornerMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Snake pattern AI (follows a snake-like path)
  Direction? _getSnakeMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateSnakeMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Evaluate the quality of a move
  double _evaluateMove(Direction direction) {
    final oldBoard = _copyBoard();
    double score = 0.0;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // Evaluate board state after move
    score += _evaluateBoardState();
    
    // Restore board
    _board = oldBoard;
    
    return score;
  }

  // Evaluate current board state
  double _evaluateBoardState() {
    double score = 0.0;
    
    // Prefer higher values in corners and edges
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final tile = _board[row][col];
        if (!tile.isEmpty) {
          final value = tile.character?.level ?? 0;
          final positionScore = _getPositionScore(row, col);
          score += value * positionScore;
        }
      }
    }
    
    // Prefer fewer empty cells (more compact board)
    final emptyCells = _countEmptyCells();
    score -= emptyCells * 10;
    
    // Prefer boards with potential merges
    score += _countPotentialMerges() * 50;
    
    return score;
  }

  // Get position score (corners and edges are better)
  double _getPositionScore(int row, int col) {
    if ((row == 0 || row == _gridSize - 1) && (col == 0 || col == _gridSize - 1)) {
      return 2.0; // Corners
    } else if (row == 0 || row == _gridSize - 1 || col == 0 || col == _gridSize - 1) {
      return 1.5; // Edges
    } else {
      return 1.0; // Center
    }
  }

  // Count empty cells
  int _countEmptyCells() {
    int count = 0;
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col].isEmpty) count++;
      }
    }
    return count;
  }

  // Count potential merges
  int _countPotentialMerges() {
    int count = 0;
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final currentTile = _board[row][col];
        if (currentTile.isEmpty) continue;
        
        // Check adjacent tiles for potential merges
        if (col + 1 < _gridSize && currentTile.canMergeWith(_board[row][col + 1])) {
          count++;
        }
        if (row + 1 < _gridSize && currentTile.canMergeWith(_board[row + 1][col])) {
          count++;
        }
      }
    }
    return count;
  }

  // Evaluate corner-focused move
  double _evaluateCornerMove(Direction direction) {
    final oldBoard = _copyBoard();
    double score = 0.0;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // Evaluate board state with corner focus
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final tile = _board[row][col];
        if (!tile.isEmpty) {
          final value = tile.character?.level ?? 0;
          final cornerScore = _getCornerPositionScore(row, col);
          score += value * cornerScore;
        }
      }
    }
    
    // Restore board
    _board = oldBoard;
    
    return score;
  }

  // Evaluate snake pattern move
  double _evaluateSnakeMove(Direction direction) {
    final oldBoard = _copyBoard();
    double score = 0.0;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // Evaluate board state with snake pattern
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final tile = _board[row][col];
        if (!tile.isEmpty) {
          final value = tile.character?.level ?? 0;
          final snakeScore = _getSnakePositionScore(row, col);
          score += value * snakeScore;
        }
      }
    }
    
    // Restore board
    _board = oldBoard;
    
    return score;
  }

  // Get corner position score (corners are much better)
  double _getCornerPositionScore(int row, int col) {
    if ((row == 0 || row == _gridSize - 1) && (col == 0 || col == _gridSize - 1)) {
      return 5.0; // Corners get very high score
    } else if (row == 0 || row == _gridSize - 1 || col == 0 || col == _gridSize - 1) {
      return 2.0; // Edges get medium score
    } else {
      return 0.5; // Center gets low score
    }
  }

  // Get snake pattern position score
  double _getSnakePositionScore(int row, int col) {
    // Snake pattern: prefer values in a snake-like path
    // Top row: left to right
    // Second row: right to left
    // Third row: left to right, etc.
    
    if (row % 2 == 0) {
      // Even rows: left to right
      return (_gridSize - col).toDouble();
    } else {
      // Odd rows: right to left
      return (col + 1).toDouble();
    }
  }

  // Edge-focused AI (prefers keeping high values on edges)
  Direction? _getEdgeMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateEdgeMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Center-focused AI (prefers keeping high values in center)
  Direction? _getCenterMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateCenterMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Random AI (randomly chooses moves)
  Direction? _getRandomMove() {
    final possibleMoves = <Direction>[];
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    // Random selection
    final random = Random();
    return possibleMoves[random.nextInt(possibleMoves.length)];
  }

  // Greedy AI (always chooses the move that gives highest immediate score)
  Direction? _getGreedyMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateGreedyMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Conservative AI (avoids risky moves, prefers safe options)
  Direction? _getConservativeMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateConservativeMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Evaluate edge-focused move
  double _evaluateEdgeMove(Direction direction) {
    final oldBoard = _copyBoard();
    double score = 0.0;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // Evaluate board state with edge focus
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final tile = _board[row][col];
        if (!tile.isEmpty) {
          final value = tile.character?.level ?? 0;
          final edgeScore = _getEdgePositionScore(row, col);
          score += value * edgeScore;
        }
      }
    }
    
    // Restore board
    _board = oldBoard;
    
    return score;
  }

  // Evaluate center-focused move
  double _evaluateCenterMove(Direction direction) {
    final oldBoard = _copyBoard();
    double score = 0.0;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // Evaluate board state with center focus
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final tile = _board[row][col];
        if (!tile.isEmpty) {
          final value = tile.character?.level ?? 0;
          final centerScore = _getCenterPositionScore(row, col);
          score += value * centerScore;
        }
      }
    }
    
    // Restore board
    _board = oldBoard;
    
    return score;
  }

  // Evaluate greedy move (immediate score gain)
  double _evaluateGreedyMove(Direction direction) {
    final oldBoard = _copyBoard();
    final oldScore = _score;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // Calculate immediate score gain
    final scoreGain = _score - oldScore;
    
    // Restore board
    _board = oldBoard;
    _score = oldScore;
    
    return scoreGain.toDouble();
  }

  // Evaluate conservative move (safety and stability)
  double _evaluateConservativeMove(Direction direction) {
    final oldBoard = _copyBoard();
    double score = 0.0;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // Evaluate safety and stability
    score += _evaluateBoardStability();
    score += _evaluateMoveSafety(direction);
    
    // Restore board
    _board = oldBoard;
    
    return score;
  }

  // Get edge position score (edges are good, corners are best)
  double _getEdgePositionScore(int row, int col) {
    if ((row == 0 || row == _gridSize - 1) && (col == 0 || col == _gridSize - 1)) {
      return 4.0; // Corners get highest score
    } else if (row == 0 || row == _gridSize - 1 || col == 0 || col == _gridSize - 1) {
      return 3.0; // Edges get high score
    } else {
      return 1.0; // Center gets low score
    }
  }

  // Get center position score (center is best)
  double _getCenterPositionScore(int row, int col) {
    final centerRow = _gridSize ~/ 2;
    final centerCol = _gridSize ~/ 2;
    final distanceFromCenter = (row - centerRow).abs() + (col - centerCol).abs();
    
    if (distanceFromCenter == 0) {
      return 5.0; // Center gets highest score
    } else if (distanceFromCenter == 1) {
      return 3.0; // Adjacent to center
    } else {
      return 1.0; // Far from center
    }
  }

  // Evaluate board stability (fewer empty cells is better)
  double _evaluateBoardStability() {
    int emptyCells = 0;
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col].isEmpty) {
          emptyCells++;
        }
      }
    }
    return (_gridSize * _gridSize - emptyCells).toDouble();
  }

  // Evaluate move safety (avoid creating isolated high values)
  double _evaluateMoveSafety(Direction direction) {
    // This is a simplified safety evaluation
    // In a real implementation, you might check for potential dead ends
    return 10.0; // Default safe score
  }

  // Advanced AI (comprehensive strategy combining multiple approaches)
  Direction? _getAdvancedMove() {
    final possibleMoves = <Direction>[];
    final moveScores = <Direction, double>{};
    
    for (final direction in [Direction.right, Direction.down, Direction.left, Direction.up]) {
      if (_canMoveInDirection(direction)) {
        possibleMoves.add(direction);
        moveScores[direction] = _evaluateAdvancedMove(direction);
      }
    }
    
    if (possibleMoves.isEmpty) return null;
    
    Direction bestMove = possibleMoves.first;
    double bestScore = moveScores[bestMove]!;
    
    for (final move in possibleMoves) {
      if (moveScores[move]! > bestScore) {
        bestScore = moveScores[move]!;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Evaluate advanced move (comprehensive strategy)
  double _evaluateAdvancedMove(Direction direction) {
    final oldBoard = _copyBoard();
    double score = 0.0;
    
    // Simulate the move
    switch (direction) {
      case Direction.up:
        _moveUp();
        break;
      case Direction.down:
        _moveDown();
        break;
      case Direction.left:
        _moveLeft();
        break;
      case Direction.right:
        _moveRight();
        break;
    }
    
    // 1. Immediate score gain (weight: 0.3)
    final scoreGain = _score - _getBoardScore(oldBoard);
    score += scoreGain * 0.3;
    
    // 2. Merge opportunities (weight: 0.25)
    score += _evaluateMergeOpportunities() * 0.25;
    
    // 3. Board structure quality (weight: 0.2)
    score += _evaluateBoardStructure() * 0.2;
    
    // 4. Future potential (weight: 0.15)
    score += _evaluateFuturePotential() * 0.15;
    
    // 5. Risk assessment (weight: 0.1)
    score += _evaluateRiskLevel() * 0.1;
    
    // Restore board
    _board = oldBoard;
    
    return score;
  }

  // Get board score from board state
  int _getBoardScore(List<List<Tile>> board) {
    int score = 0;
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (!board[row][col].isEmpty) {
          score += (board[row][col].character?.level ?? 0) * 10;
        }
      }
    }
    return score;
  }

  // Evaluate merge opportunities
  double _evaluateMergeOpportunities() {
    double opportunities = 0.0;
    
    // Check horizontal merge opportunities
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize - 1; col++) {
        final current = _board[row][col];
        final next = _board[row][col + 1];
        if (!current.isEmpty && !next.isEmpty && 
            current.character?.level == next.character?.level) {
          opportunities += current.character?.level ?? 0;
        }
      }
    }
    
    // Check vertical merge opportunities
    for (int row = 0; row < _gridSize - 1; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final current = _board[row][col];
        final next = _board[row + 1][col];
        if (!current.isEmpty && !next.isEmpty && 
            current.character?.level == next.character?.level) {
          opportunities += current.character?.level ?? 0;
        }
      }
    }
    
    return opportunities;
  }

  // Evaluate board structure quality
  double _evaluateBoardStructure() {
    double structureScore = 0.0;
    
    // Prefer monotonic sequences (increasing/decreasing)
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize - 1; col++) {
        final current = _board[row][col];
        final next = _board[row][col + 1];
        if (!current.isEmpty && !next.isEmpty) {
          final currentLevel = current.character?.level ?? 0;
          final nextLevel = next.character?.level ?? 0;
          if (currentLevel >= nextLevel) {
            structureScore += currentLevel;
          }
        }
      }
    }
    
    // Prefer high values in corners
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if ((row == 0 || row == _gridSize - 1) && (col == 0 || col == _gridSize - 1)) {
          final tile = _board[row][col];
          if (!tile.isEmpty) {
            structureScore += (tile.character?.level ?? 0) * 2;
          }
        }
      }
    }
    
    return structureScore;
  }

  // Evaluate future potential
  double _evaluateFuturePotential() {
    double potential = 0.0;
    
    // Count empty cells (more empty cells = more potential)
    int emptyCells = 0;
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_board[row][col].isEmpty) {
          emptyCells++;
        }
      }
    }
    potential += emptyCells * 10;
    
    // Prefer having a clear path for high values
    potential += _evaluatePathClarity();
    
    return potential;
  }

  // Evaluate path clarity (how clear the path is for high values)
  double _evaluatePathClarity() {
    double clarity = 0.0;
    
    // Check if high values can move freely
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final tile = _board[row][col];
        if (!tile.isEmpty) {
          final level = tile.character?.level ?? 0;
          if (level > 3) { // High value tiles
            // Check if they can move in any direction
            int movableDirections = 0;
            if (col > 0 && _board[row][col - 1].isEmpty) movableDirections++;
            if (col < _gridSize - 1 && _board[row][col + 1].isEmpty) movableDirections++;
            if (row > 0 && _board[row - 1][col].isEmpty) movableDirections++;
            if (row < _gridSize - 1 && _board[row + 1][col].isEmpty) movableDirections++;
            clarity += level * movableDirections;
          }
        }
      }
    }
    
    return clarity;
  }

  // Evaluate risk level
  double _evaluateRiskLevel() {
    double risk = 0.0;
    
    // Higher risk if board is getting full
    int filledCells = 0;
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (!_board[row][col].isEmpty) {
          filledCells++;
        }
      }
    }
    
    final fillRatio = filledCells / (_gridSize * _gridSize);
    if (fillRatio > 0.8) {
      risk -= 50; // High risk when board is nearly full
    }
    
    // Lower risk if we have good merge opportunities
    risk += _evaluateMergeOpportunities();
    
    return risk;
  }
} 