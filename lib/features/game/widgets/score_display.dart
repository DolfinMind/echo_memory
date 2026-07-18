/// Score display widget for Echo Memory
/// Animated score counter with effects
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class ScoreDisplay extends StatefulWidget {
  final int score;
  final bool animate;
  final bool showLabel;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.animate = true,
    this.showLabel = true,
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showLabel)
                Text(
                  'SCORE',
                  style: AppTextStyles.labelSmall.copyWith(
                    letterSpacing: 2,
                    color: AppColors.textMuted,
                  ),
                ),
              // Implicitly animate the score number
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: widget.score),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    value.toString().padLeft(5, '0'),
                    style: AppTextStyles.score,
                  );
                },
              ),
            ],
          ),
        )
        .animate(target: widget.animate ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }
}

/// Circular timer widget
class CircularTimer extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;
  final double size;
  final bool showText;

  const CircularTimer({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
    this.size = 80,
    this.showText = true,
  });

  double get progress => totalTime > 0 ? timeRemaining / totalTime : 0;
  bool get isCritical => timeRemaining <= 3;

  Color get progressColor {
    if (isCritical) return AppColors.accentError;
    if (progress < 0.3) return AppColors.accentWarning;
    return AppColors.accentSuccess;
  }

  @override
  Widget build(BuildContext context) {
    Widget timer = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textMuted.withValues(alpha: 0.2),
              ),
            ),
          ),
          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          // Time text
          if (showText)
            Text(
              '$timeRemaining',
              style: AppTextStyles.labelLarge.copyWith(
                color: progressColor,
                fontSize: size * 0.32,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );

    return timer;
  }
}

/// Lives display with animated hearts
class LivesDisplay extends StatelessWidget {
  final int lives;
  final int maxLives;
  final double size;

  const LivesDisplay({
    super.key,
    required this.lives,
    this.maxLives = 3,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    // Zen mode check (or large lives count)
    if (maxLives > 20) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.infinity,
            color: AppColors.accentWarning,
            size: size,
          ),
          const SizedBox(width: 4),
          Icon(
            LucideIcons.heart,
            color: AppColors.accentError,
            size: size * 0.6,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isActive = index < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child:
              Icon(
                    isActive ? LucideIcons.heart : LucideIcons.heartOff,
                    color: isActive
                        ? AppColors.accentError
                        : AppColors.textMuted.withValues(alpha: 0.3),
                    size: size,
                  )
                  .animate()
                  .fadeIn(delay: (index * 100).ms)
                  .scale(delay: (index * 100).ms),
        );
      }),
    );
  }
}

/// Level indicator
class LevelIndicator extends StatelessWidget {
  final int level;
  final int sequenceLength;

  const LevelIndicator({
    super.key,
    required this.level,
    required this.sequenceLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.orbPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.orbPurple.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.layers, color: AppColors.orbPurple, size: 18),
          const SizedBox(width: 8),
          Text(
            'Level $level',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.orbPurple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$sequenceLength colors',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
