import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/game_models.dart';

class GamePainter extends CustomPainter {
  final GameState state;
  final ui.Image? headImage;
  final ui.Image? foodImage;

  GamePainter(this.state, {this.headImage, this.foodImage});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / state.gridSize;

    // Draw grid
    _drawGrid(canvas, size, cellSize);

    // Draw food
    _drawFood(canvas, cellSize);

    // Draw snake
    _drawSnake(canvas, cellSize);
  }

  void _drawGrid(Canvas canvas, Size size, double cellSize) {
    final paint = Paint()
      ..color = const Color(0xFF00F5A0).withOpacity(0.08)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= state.gridSize; i++) {
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
    }
  }

  void _drawFood(Canvas canvas, double cellSize) {
    final food = state.food;
    final center = Offset(
      food.x * cellSize + cellSize / 2,
      food.y * cellSize + cellSize / 2,
    );
    final radius = cellSize * 0.45;

    if (foodImage != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawImageRect(
        foodImage!,
        Rect.fromLTWH(0, 0, foodImage!.width.toDouble(), foodImage!.height.toDouble()),
        rect,
        Paint(),
      );
      return;
    }

    // Glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFFFF4757).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Food body
    final gradient = RadialGradient(colors: [
      const Color(0xFFFF6B81),
      const Color(0xFFFF4757),
    ]);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final foodPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, foodPaint);

    // Shine
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
      radius * 0.2,
      shinePaint,
    );
  }

  void _drawSnake(Canvas canvas, double cellSize) {
    final snake = state.snake;
    final padding = cellSize * 0.08;

    for (int i = 0; i < snake.length; i++) {
      final point = snake[i];
      final rect = Rect.fromLTWH(
        point.x * cellSize + padding,
        point.y * cellSize + padding,
        cellSize - padding * 2,
        cellSize - padding * 2,
      );

      final t = i / snake.length.toDouble();

      if (i == 0) {
        // Head
        _drawHead(canvas, rect, cellSize);
      } else {
        // Body with gradient
        final color = Color.lerp(
          const Color(0xFF00F5A0),
          const Color(0xFF00B4D8),
          t,
        )!;

        // Glow
        final glowPaint = Paint()
          ..color = color.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(4)),
          glowPaint,
        );

        // Body segment
        final bodyPaint = Paint()..color = color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          bodyPaint,
        );
      }
    }
  }

  void _drawHead(Canvas canvas, Rect rect, double cellSize) {
    if (headImage != null) {
      final center = rect.center;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      
      // Rotate head based on direction
      double rotation = 0;
      switch (state.direction) {
        case Direction.right:
          rotation = 0;
          break;
        case Direction.down:
          rotation = 3.14159 / 2;
          break;
        case Direction.left:
          rotation = 3.14159;
          break;
        case Direction.up:
          rotation = -3.14159 / 2;
          break;
      }
      canvas.rotate(rotation);
      
      final drawRect = Rect.fromCenter(center: Offset.zero, width: rect.width * 1.2, height: rect.height * 1.2);
      
      // Draw head image
      canvas.drawImageRect(
        headImage!,
        Rect.fromLTWH(0, 0, headImage!.width.toDouble(), headImage!.height.toDouble()),
        drawRect,
        Paint(),
      );
      
      canvas.restore();
      return;
    }

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00F5A0).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(6)),
      glowPaint,
    );

    // Head body
    final gradient = LinearGradient(colors: [
      const Color(0xFF00F5A0),
      const Color(0xFF00D4A0),
    ], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final headPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      headPaint,
    );

    // Eyes
    final eyeRadius = cellSize * 0.09;
    final eyePaint = Paint()..color = const Color(0xFF0A0E1A);

    final dir = state.direction;
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final offset = cellSize * 0.15;

    Offset eye1, eye2;
    switch (dir) {
      case Direction.right:
        eye1 = Offset(cx + offset, cy - offset);
        eye2 = Offset(cx + offset, cy + offset);
        break;
      case Direction.left:
        eye1 = Offset(cx - offset, cy - offset);
        eye2 = Offset(cx - offset, cy + offset);
        break;
      case Direction.up:
        eye1 = Offset(cx - offset, cy - offset);
        eye2 = Offset(cx + offset, cy - offset);
        break;
      case Direction.down:
        eye1 = Offset(cx - offset, cy + offset);
        eye2 = Offset(cx + offset, cy + offset);
        break;
    }

    canvas.drawCircle(eye1, eyeRadius, eyePaint);
    canvas.drawCircle(eye2, eyeRadius, eyePaint);

    // Eye shine
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(
        Offset(eye1.dx + eyeRadius * 0.3, eye1.dy - eyeRadius * 0.3),
        eyeRadius * 0.35,
        shinePaint);
    canvas.drawCircle(
        Offset(eye2.dx + eyeRadius * 0.3, eye2.dy - eyeRadius * 0.3),
        eyeRadius * 0.35,
        shinePaint);
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
