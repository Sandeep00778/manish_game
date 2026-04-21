import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../controllers/game_controller.dart';
import '../models/game_models.dart';
import '../widgets/game_painter.dart';
import '../widgets/dpad_controller.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  late FocusNode _focusNode;
  ui.Image? _headImage;
  ui.Image? _foodImage;
  ui.Image? _smaptImage;

  Offset? _swipeStart;

  @override
  void initState() {
    super.initState();
    _controller = GameController(difficulty: widget.difficulty);
    _controller.addListener(() => setState(() {}));
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _loadImages();
    });
  }

  Future<void> _loadImages() async {
    final headData = await rootBundle.load('assets/images/manish.jpg');
    final foodData = await rootBundle.load('assets/images/kamran.jpg');
    final smaptData = await rootBundle.load('assets/images/smapt.jpg');
    
    final headCodec = await ui.instantiateImageCodec(headData.buffer.asUint8List());
    final foodCodec = await ui.instantiateImageCodec(foodData.buffer.asUint8List());
    final smaptCodec = await ui.instantiateImageCodec(smaptData.buffer.asUint8List());
    
    final headFrame = await headCodec.getNextFrame();
    final foodFrame = await foodCodec.getNextFrame();
    final smaptFrame = await smaptCodec.getNextFrame();
    
    if (mounted) {
      setState(() {
        _headImage = headFrame.image;
        _foodImage = foodFrame.image;
        _smaptImage = smaptFrame.image;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _controller.changeDirection(Direction.up);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _controller.changeDirection(Direction.down);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _controller.changeDirection(Direction.left);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _controller.changeDirection(Direction.right);
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            if (_controller.state.status == GameStatus.playing) {
              _controller.pauseGame();
            } else if (_controller.state.status == GameStatus.paused) {
              _controller.resumeGame();
            } else if (_controller.state.status == GameStatus.idle) {
              _controller.startGame();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: SafeArea(
          child: Stack(
            children: [
              // Board Background / Grid
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate largest square that fits
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    final boardSize = size - 20;
                    return Center(
                      child: _buildBoard(state, boardSize),
                    );
                  },
                ),
              ),
              // Top Bar Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(state),
              ),
              // Difficulty / Stats Overlay at bottom
              if (state.status == GameStatus.playing || state.status == GameStatus.paused)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildMiniStats(state)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          _IconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              _controller.pauseGame();
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          // Score
          _ScoreBadge(
            label: 'SCORE',
            value: state.score.toString(),
            color: const Color(0xFF00F5A0),
          ),
          const SizedBox(width: 12),
          _ScoreBadge(
            label: 'BEST',
            value: state.highScore.toString(),
            color: const Color(0xFF00D9F5),
          ),
          const Spacer(),
          // Pause button
          _IconBtn(
            icon: state.status == GameStatus.paused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              if (state.status == GameStatus.playing) {
                _controller.pauseGame();
              } else if (state.status == GameStatus.paused) {
                _controller.resumeGame();
              } else if (state.status == GameStatus.idle) {
                _controller.startGame();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(GameState state, double boardSize) {
    return GestureDetector(
      onPanStart: (details) => _swipeStart = details.localPosition,
      onPanEnd: (details) {
        if (_swipeStart == null) return;
        final delta = details.velocity.pixelsPerSecond;
        if (delta.dx.abs() > delta.dy.abs()) {
          _controller.changeDirection(
              delta.dx > 0 ? Direction.right : Direction.left);
        } else {
          _controller.changeDirection(
              delta.dy > 0 ? Direction.down : Direction.up);
        }
        _swipeStart = null;
      },
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1526),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00F5A0).withOpacity(0.6), // Increased opacity
            width: 3.0, // Thicker border
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5A0).withOpacity(0.2), // Stronger glow
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(boardSize, boardSize),
                painter: GamePainter(state, headImage: _headImage, foodImage: _foodImage),
              ),
              if (state.status == GameStatus.idle) _buildStartOverlay(),
              if (state.status == GameStatus.paused) _buildPauseOverlay(),
              if (state.status == GameStatus.gameOver) _buildGameOverOverlay(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartOverlay() {
    return _Overlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🐍', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'SNAKE',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00F5A0),
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _controller.state.difficulty.label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF00D9F5),
              fontSize: 14,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 32),
          _GlowButton(
            label: 'START GAME',
            onTap: () {
              HapticFeedback.mediumImpact();
              _controller.startGame();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return _Overlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pause_circle_filled_rounded,
              color: Color(0xFF00D9F5), size: 64),
          const SizedBox(height: 16),
          const Text(
            'PAUSED',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 32),
          _GlowButton(
            label: 'RESUME',
            onTap: () {
              HapticFeedback.lightImpact();
              _controller.resumeGame();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay(GameState state) {
    return _Overlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_smaptImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 120,
                height: 120,
                child: RawImage(
                  image: _smaptImage!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            const Text('💀', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Khel Samaptam',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF4757),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5A0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF00F5A0).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '${state.score}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00F5A0),
                  ),
                ),
                const Text(
                  'POINTS',
                  style: TextStyle(
                    color: Color(0xFF6B7A99),
                    fontSize: 12,
                    letterSpacing: 3,
                  ),
                ),
                if (state.score > 0 && state.score == state.highScore) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🏆 NEW HIGH SCORE!',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _GlowButton(
            label: 'PLAY AGAIN',
            onTap: () {
              HapticFeedback.mediumImpact();
              _controller.startGame();
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Main Menu',
              style: TextStyle(color: Color(0xFF6B7A99), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStats(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2D45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed_rounded, color: Color(0xFF6B7A99), size: 14),
          const SizedBox(width: 6),
          Text(
            state.difficulty.label,
            style: const TextStyle(
              color: Color(0xFF6B7A99),
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '• ${state.snake.length} segments',
            style: const TextStyle(
              color: Color(0xFF4B5568),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  final Widget child;
  const _Overlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(child: child),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00F5A0), Color(0xFF00B4D8)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5A0).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0A0E1A),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.6),
              fontSize: 9,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2D45)),
        ),
        child: Icon(icon, color: const Color(0xFF6B7A99), size: 20),
      ),
    );
  }
}
