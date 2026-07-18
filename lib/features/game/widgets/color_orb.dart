import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../config/theme/app_colors.dart';

const _orbNames = ['Coral', 'Mint', 'Blue', 'Gold', 'Violet'];
const _orbIcons = [
  LucideIcons.flame,
  LucideIcons.leaf,
  LucideIcons.droplet,
  LucideIcons.sun,
  LucideIcons.diamond,
];

/// A color control with shape reinforcement for color-vision accessibility.
class ColorOrb extends StatelessWidget {
  final int colorIndex;
  final double size;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isHighlighted;
  final bool showRipple;

  const ColorOrb({
    super.key,
    required this.colorIndex,
    this.size = 80,
    this.onTap,
    this.isDisabled = false,
    this.isHighlighted = false,
    this.showRipple = false,
  });

  @override
  Widget build(BuildContext context) {
    final index = colorIndex % AppColors.gameOrbs.length;
    final color = AppColors.gameOrbs[index];
    final glow = AppColors.gameOrbGlows[index];
    final showColor = isHighlighted || !isDisabled;
    final diameter = size.clamp(56, 104).toDouble();

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: '${_orbNames[index]} memory button',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: isHighlighted ? 1.08 : 1),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: SizedBox.square(
          dimension: diameter + 16,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.25, -0.3),
                  colors: showColor
                      ? [glow, color, color.withValues(alpha: 0.78)]
                      : [AppColors.surfaceLight, AppColors.surface],
                ),
                border: Border.all(
                  color: isHighlighted
                      ? AppColors.textPrimary
                      : AppColors.cardBorder,
                  width: isHighlighted ? 3 : 1.5,
                ),
                boxShadow: isHighlighted
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.55),
                          blurRadius: 24,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: InkWell(
                onTap: isDisabled ? null : onTap,
                customBorder: const CircleBorder(),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: showColor ? 1 : 0.32,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      _orbIcons[index],
                      color: AppColors.textPrimary,
                      size: diameter * 0.34,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PatternOrb extends StatelessWidget {
  final int colorIndex;
  final int index;
  final double size;
  final bool animateIn;

  const PatternOrb({
    super.key,
    required this.colorIndex,
    required this.index,
    this.size = 50,
    this.animateIn = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget orb = ColorOrb(
      colorIndex: colorIndex,
      size: size,
      isDisabled: true,
      isHighlighted: true,
    );
    if (animateIn) {
      orb = orb
          .animate()
          .fadeIn(delay: (index * 80).ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 220.ms);
    }
    return orb;
  }
}
