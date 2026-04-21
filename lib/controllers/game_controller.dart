import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_models.dart';

class GameController extends ChangeNotifier {
  GameState _state;
  Timer? _timer;
  Direction _pendingDirection;

  GameController({Difficulty difficulty = Difficulty.medium})
      : _state = GameState.initial(difficulty),
        _pendingDirection = Direction.right;

  GameState get state => _state;

  void setDifficulty(Difficulty d) {
    _state = GameState.initial(d).copyWith(highScore: _state.highScore);
    notifyListeners();
  }

  void startGame() {
    final freshState = GameState.initial(_state.difficulty)
        .copyWith(highScore: _state.highScore, status: GameStatus.playing);
    _state = freshState;
    _pendingDirection = Direction.right;
    notifyListeners();
    _startTimer();
  }

  void pauseGame() {
    if (_state.status == GameStatus.playing) {
      _timer?.cancel();
      _state = _state.copyWith(status: GameStatus.paused);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state.status == GameStatus.paused) {
      _state = _state.copyWith(status: GameStatus.playing);
      notifyListeners();
      _startTimer();
    }
  }

  void changeDirection(Direction dir) {
    if (!dir.isOpposite(_state.direction)) {
      _pendingDirection = dir;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _state.difficulty.tickMs),
      (_) => _tick(),
    );
  }

  void _tick() {
    if (_state.status != GameStatus.playing) return;

    final dir = _pendingDirection;
    if (!dir.isOpposite(_state.direction)) {
      _state = _state.copyWith(direction: dir);
    }

    final newHead = _state.snake.first + _state.direction.delta;

    // Wrap coordinates for edges
    final x = (newHead.x + _state.gridSize) % _state.gridSize;
    final y = (newHead.y + _state.gridSize) % _state.gridSize;
    final wrappedHead = Point(x, y);

    // Self collision
    if (_state.snake.contains(wrappedHead)) {
      _endGame();
      return;
    }

    final ateFood = wrappedHead == _state.food;
    final newSnake = [wrappedHead, ..._state.snake];
    if (!ateFood) newSnake.removeLast();

    final newScore = ateFood ? _state.score + 10 : _state.score;
    final newHighScore =
        newScore > _state.highScore ? newScore : _state.highScore;
    final newFood =
        ateFood ? GameState.randomFood(_state.gridSize, newSnake) : _state.food;

    _state = _state.copyWith(
      snake: newSnake,
      food: newFood,
      score: newScore,
      highScore: newHighScore,
    );

    if (ateFood) _restartTimer();
    notifyListeners();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _state.difficulty.tickMs),
      (_) => _tick(),
    );
  }

  void _endGame() {
    _timer?.cancel();
    _state = _state.copyWith(status: GameStatus.gameOver);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
