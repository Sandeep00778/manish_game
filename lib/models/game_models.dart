import 'dart:math';

class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);

  Point operator +(Point other) => Point(x + other.x, y + other.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

enum Direction { up, down, left, right }

extension DirectionExtension on Direction {
  Point get delta {
    switch (this) {
      case Direction.up:
        return const Point(0, -1);
      case Direction.down:
        return const Point(0, 1);
      case Direction.left:
        return const Point(-1, 0);
      case Direction.right:
        return const Point(1, 0);
    }
  }

  bool isOpposite(Direction other) {
    switch (this) {
      case Direction.up:
        return other == Direction.down;
      case Direction.down:
        return other == Direction.up;
      case Direction.left:
        return other == Direction.right;
      case Direction.right:
        return other == Direction.left;
    }
  }
}

enum GameStatus { idle, playing, paused, gameOver }

enum Difficulty { easy, medium, hard }

extension DifficultyExtension on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  int get tickMs {
    switch (this) {
      case Difficulty.easy:
        return 220;
      case Difficulty.medium:
        return 140;
      case Difficulty.hard:
        return 80;
    }
  }
}

class GameState {
  final List<Point> snake;
  final Point food;
  final Direction direction;
  final GameStatus status;
  final int score;
  final int highScore;
  final Difficulty difficulty;
  final int gridSize;

  const GameState({
    required this.snake,
    required this.food,
    required this.direction,
    required this.status,
    required this.score,
    required this.highScore,
    required this.difficulty,
    required this.gridSize,
  });

  GameState copyWith({
    List<Point>? snake,
    Point? food,
    Direction? direction,
    GameStatus? status,
    int? score,
    int? highScore,
    Difficulty? difficulty,
    int? gridSize,
  }) {
    return GameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      difficulty: difficulty ?? this.difficulty,
      gridSize: gridSize ?? this.gridSize,
    );
  }

  static Point randomFood(int gridSize, List<Point> snake) {
    final rand = Random();
    Point food;
    do {
      food = Point(rand.nextInt(gridSize), rand.nextInt(gridSize));
    } while (snake.contains(food));
    return food;
  }

  static GameState initial(Difficulty difficulty) {
    const gridSize = 20;
    const initialSnake = [Point(10, 10), Point(9, 10), Point(8, 10)];
    return GameState(
      snake: initialSnake,
      food: randomFood(gridSize, initialSnake),
      direction: Direction.right,
      status: GameStatus.idle,
      score: 0,
      highScore: 0,
      difficulty: difficulty,
      gridSize: gridSize,
    );
  }
}
