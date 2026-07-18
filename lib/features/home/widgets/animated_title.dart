/// Animated game title widget for Echo Memory
/// Premium title with glow and shimmer effects
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class AnimatedGameTitle extends StatelessWidget {
  final double fontSize;

  const AnimatedGameTitle({super.key, this.fontSize = 52});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppColors.auroraGradient,
          ).createShader(bounds),
          child: Text(
            'Echo Memory',
            style: AppTextStyles.gameTitle.copyWith(fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(
          duration: 2000.ms,
          color: Colors.white.withValues(alpha: 0.3),
          delay: 500.ms,
        );
  }
}

/// Smaller title for in-game headers
class GameTitleSmall extends StatelessWidget {
  const GameTitleSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: AppColors.auroraGradient,
      ).createShader(bounds),
      child: Text(
        'Echo Memory',
        style: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
