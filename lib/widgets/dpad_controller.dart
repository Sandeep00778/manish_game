import 'package:flutter/material.dart';
import '../models/game_models.dart';

class DpadController extends StatelessWidget {
  final void Function(Direction) onDirection;

  const DpadController({super.key, required this.onDirection});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111827),
              border: Border.all(color: const Color(0xFF1F2D45), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F5A0).withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Up
          Positioned(
            top: 10,
            child: _DpadButton(
              icon: Icons.keyboard_arrow_up_rounded,
              onTap: () => onDirection(Direction.up),
            ),
          ),

          // Down
          Positioned(
            bottom: 10,
            child: _DpadButton(
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: () => onDirection(Direction.down),
            ),
          ),

          // Left
          Positioned(
            left: 10,
            child: _DpadButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onTap: () => onDirection(Direction.left),
            ),
          ),

          // Right
          Positioned(
            right: 10,
            child: _DpadButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onTap: () => onDirection(Direction.right),
            ),
          ),

          // Center circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A2035),
              border:
                  Border.all(color: const Color(0xFF00F5A0).withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DpadButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DpadButton({required this.icon, required this.onTap});

  @override
  State<_DpadButton> createState() => _DpadButtonState();
}

class _DpadButtonState extends State<_DpadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTap();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onLongPressStart: (_) {
        setState(() => _pressed = true);
        widget.onTap();
      },
      onLongPressEnd: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? const Color(0xFF00F5A0).withOpacity(0.25)
              : const Color(0xFF1A2540),
          border: Border.all(
            color: _pressed
                ? const Color(0xFF00F5A0)
                : const Color(0xFF2A3555),
            width: 1.5,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F5A0).withOpacity(0.4),
                    blurRadius: 12,
                  )
                ]
              : [],
        ),
        child: Icon(
          widget.icon,
          color: _pressed ? const Color(0xFF00F5A0) : const Color(0xFF6B7A99),
          size: 28,
        ),
      ),
    );
  }
}
