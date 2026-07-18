/// Celebration overlay for Echo Memory
/// Confetti, explosions, and victory animations
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class CelebrationOverlay extends StatefulWidget {
  final CelebrationType type;
  final VoidCallback? onComplete;
  final Duration duration;

  const CelebrationOverlay({
    super.key,
    required this.type,
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Confetti> _confetti;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });

    _initConfetti();
    _controller.forward();
  }

  void _initConfetti() {
    final count = widget.type == CelebrationType.legendary ? 100 : 50;
    final colors = _getColors();

    _confetti = List.generate(count, (index) {
      return _Confetti(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5,
        size: _random.nextDouble() * 10 + 5,
        color: colors[_random.nextInt(colors.length)],
        rotation: _random.nextDouble() * 360,
        rotationSpeed: _random.nextDouble() * 360 - 180,
        velocity: _random.nextDouble() * 0.5 + 0.3,
        horizontalDrift: _random.nextDouble() * 0.4 - 0.2,
      );
    });
  }

  List<Color> _getColors() {
    switch (widget.type) {
      case CelebrationType.levelComplete:
        return [AppColors.orbGreen, AppColors.orbBlue, AppColors.accentGold];
      case CelebrationType.newHighScore:
        return AppColors.auroraGradient;
      case CelebrationType.legendary:
        return [
          AppColors.accentGold,
          AppColors.orbRed,
          AppColors.orbPurple,
          Colors.white,
        ];
      case CelebrationType.achievement:
        return [AppColors.accentGold, Colors.white, AppColors.orbBlue];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Screen flash
            if (_controller.value < 0.1)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(
                    alpha: (1 - _controller.value * 10).clamp(0, 0.3),
                  ),
                ),
              ),

            // Confetti
            CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(
                confetti: _confetti,
                progress: _controller.value,
              ),
            ),

            // Center burst for legendary
            if (widget.type == CelebrationType.legendary &&
                _controller.value < 0.3)
              Center(
                child: Container(
                  width: 200 * (1 + _controller.value * 3),
                  height: 200 * (1 + _controller.value * 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentGold.withValues(
                          alpha: (1 - _controller.value * 3.3).clamp(0, 0.8),
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

enum CelebrationType { levelComplete, newHighScore, legendary, achievement }

class _Confetti {
  double x;
  double y;
  final double size;
  final Color color;
  double rotation;
  final double rotationSpeed;
  final double velocity;
  final double horizontalDrift;

  _Confetti({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.velocity,
    required this.horizontalDrift,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confetti) {
      // Update position
      final y = c.y + progress * c.velocity * 1.5;
      final x = c.x + math.sin(progress * math.pi * 2) * c.horizontalDrift;
      final rotation =
          (c.rotation + progress * c.rotationSpeed) * math.pi / 180;

      // Skip if out of bounds
      if (y > 1.2) continue;

      // Calculate opacity (fade out near bottom)
      final opacity = y > 0.8 ? (1.2 - y) / 0.4 : 1.0;

      final paint = Paint()
        ..color = c.color.withValues(alpha: opacity.clamp(0, 1))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rotation);

      // Draw confetti shape (rectangle or circle)
      if (confetti.indexOf(c) % 2 == 0) {
        // Rectangle
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: c.size,
            height: c.size * 0.6,
          ),
          paint,
        );
      } else {
        // Circle
        canvas.drawCircle(Offset.zero, c.size * 0.4, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Screen shake effect
class ScreenShake extends StatefulWidget {
  final Widget child;
  final bool shake;
  final double intensity;
  final Duration duration;
  final VoidCallback? onComplete;

  const ScreenShake({
    super.key,
    required this.child,
    this.shake = false,
    this.intensity = 8.0,
    this.duration = const Duration(milliseconds: 300),
    this.onComplete,
  });

  @override
  State<ScreenShake> createState() => _ScreenShakeState();
}

class _ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });
  }

  @override
  void didUpdateWidget(ScreenShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isAnimating) {
          return widget.child;
        }

        final decay = 1 - _controller.value;
        final offsetX =
            (_random.nextDouble() * 2 - 1) * widget.intensity * decay;
        final offsetY =
            (_random.nextDouble() * 2 - 1) * widget.intensity * decay;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: widget.child,
        );
      },
    );
  }
}

/// Pulse ring effect
class PulseRing extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulseRing({
    super.key,
    required this.color,
    this.size = 100,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + _controller.value * 0.5;
        final opacity = (1 - _controller.value).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withValues(alpha: opacity),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
