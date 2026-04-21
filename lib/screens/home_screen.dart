import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_models.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Difficulty _selectedDifficulty = Difficulty.medium;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 48),
                    _buildDifficultySelector(),
                    const SizedBox(height: 40),
                    _buildPlayButton(),
                    const SizedBox(height: 48),
                    _buildInstructions(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _BackgroundPainter(),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: child,
          ),
          child: const Text('🐍', style: TextStyle(fontSize: 80)),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
          ).createShader(bounds),
          child: const Text(
            'SNAKE',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'CLASSIC ARCADE',
          style: TextStyle(
            color: Color(0xFF4B5568),
            fontSize: 12,
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      children: [
        const Text(
          'SELECT DIFFICULTY',
          style: TextStyle(
            color: Color(0xFF6B7A99),
            fontSize: 11,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: Difficulty.values.map((d) {
            final isSelected = d == _selectedDifficulty;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedDifficulty = d);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF00F5A0), Color(0xFF00B4D8)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFF1F2D45),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00F5A0).withOpacity(0.3),
                            blurRadius: 16,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: Text(
                  d.label.toUpperCase(),
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF0A0E1A) : const Color(0xFF6B7A99),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(
        scale: _pulseAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => GameScreen(
                difficulty: _selectedDifficulty,
              ),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF00F5A0), Color(0xFF00B4D8)],
              center: Alignment(-0.3, -0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5A0).withOpacity(0.35),
                blurRadius: 40,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: const Color(0xFF00B4D8).withOpacity(0.2),
                blurRadius: 60,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded,
                  color: Color(0xFF0A0E1A), size: 72),
              Text(
                'PLAY',
                style: TextStyle(
                  color: Color(0xFF0A0E1A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2D45)),
      ),
      child: Column(
        children: [
          const Text(
            'HOW TO PLAY',
            style: TextStyle(
              color: Color(0xFF6B7A99),
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InstructionItem(icon: '👆', text: 'Swipe\nto move'),
              _InstructionItem(icon: '🍎', text: 'Eat food\nto grow'),
              _InstructionItem(icon: '💥', text: 'Avoid\nwalls'),
              _InstructionItem(icon: '💀', text: 'Don\'t\nhit yourself'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF4B5568),
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top-right glow
    paint.color = const Color(0xFF00F5A0).withOpacity(0.04);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.15), 200, paint);

    // Bottom-left glow
    paint.color = const Color(0xFF00D9F5).withOpacity(0.04);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.85), 200, paint);

    // Center subtle glow
    paint.color = const Color(0xFF00F5A0).withOpacity(0.02);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), 300, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
