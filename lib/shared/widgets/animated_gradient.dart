/// Animated gradient background widget for Echo Memory
/// Creates beautiful moving gradient backgrounds
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;
  final bool animate;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 10),
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColors = colors ?? AppColors.auroraGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColors,
        ),
      ),
      child: child,
    );
  }
}

/// Static deep dark gradient for game screens
class GameGradientBackground extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const GameGradientBackground({
    super.key,
    required this.child,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gameBackground),
      child: Stack(
        children: [
          if (showOverlay)
            Positioned.fill(child: CustomPaint(painter: _GridOverlayPainter())),
          child,
        ],
      ),
    );
  }
}

/// Grid overlay painter for cyberpunk effect
class _GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating particles background - Optimized
class ParticleBackground extends StatelessWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 20, // Reduced from 30 for better performance
    this.particleColor = Colors.white,
  });

  List<_Particle> _particles() {
    final random = math.Random(42);
    return List.generate(
      particleCount,
      (_) => _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.5 + 0.1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(child: child),
        IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              particles: _particles(),
              color: particleColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final particle in particles) {
      paint.color = color.withValues(alpha: particle.opacity);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}
