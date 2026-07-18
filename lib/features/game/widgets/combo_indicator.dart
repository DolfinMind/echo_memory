/// Combo indicator widget for Echo Memory
/// Shows combo status with animated text and effects
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/constants/game_constants.dart';

class ComboIndicator extends StatelessWidget {
  final int streak;
  final bool showAnimation;

  const ComboIndicator({
    super.key,
    required this.streak,
    this.showAnimation = true,
  });

  String get comboText {
    if (streak >= GameConstants.comboLegendaryThreshold) return 'LEGENDARY!';
    if (streak >= GameConstants.comboFireThreshold) return 'ON FIRE!';
    if (streak >= GameConstants.comboAmazingThreshold) return 'AMAZING!';
    if (streak >= GameConstants.comboGoodThreshold) return 'GOOD!';
    return '';
  }

  Color get comboColor {
    if (streak >= GameConstants.comboLegendaryThreshold) {
      return AppColors.comboLegendary;
    }
    if (streak >= GameConstants.comboFireThreshold) return AppColors.comboFire;
    if (streak >= GameConstants.comboAmazingThreshold) {
      return AppColors.comboAmazing;
    }
    if (streak >= GameConstants.comboGoodThreshold) return AppColors.comboGood;
    return Colors.transparent;
  }

  double get multiplier {
    if (streak >= GameConstants.comboLegendaryThreshold) {
      return GameConstants.comboLegendaryMultiplier;
    }
    if (streak >= GameConstants.comboFireThreshold) {
      return GameConstants.comboFireMultiplier;
    }
    if (streak >= GameConstants.comboAmazingThreshold) {
      return GameConstants.comboAmazingMultiplier;
    }
    if (streak >= GameConstants.comboGoodThreshold) {
      return GameConstants.comboGoodMultiplier;
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (streak < GameConstants.comboGoodThreshold) {
      return const SizedBox.shrink();
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Combo text
        Text(
          comboText,
          style: AppTextStyles.withGlow(
            AppTextStyles.combo.copyWith(
              color: comboColor,
              fontSize: _getFontSize(),
            ),
            comboColor,
          ),
        ),
        const SizedBox(height: 4),
        // Multiplier badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: comboColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: comboColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: comboColor.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            '${multiplier}x',
            style: AppTextStyles.labelLarge.copyWith(
              color: comboColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Streak counter
        Text(
          '$streak streak',
          style: AppTextStyles.bodySmall.copyWith(
            color: comboColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );

    if (showAnimation) {
      content = content
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, color: comboColor.withValues(alpha: 0.3));

      // Add fire effect for high combos
      if (streak >= GameConstants.comboFireThreshold) {
        content = Stack(
          alignment: Alignment.center,
          children: [
            // Fire particles behind text
            _buildFireEffect(),
            content,
          ],
        );
      }
    }

    return content;
  }

  double _getFontSize() {
    if (streak >= GameConstants.comboLegendaryThreshold) return 36;
    if (streak >= GameConstants.comboFireThreshold) return 32;
    if (streak >= GameConstants.comboAmazingThreshold) return 28;
    return 24;
  }

  Widget _buildFireEffect() {
    return SizedBox(
      width: 150,
      height: 80,
      child: Stack(
        children: List.generate(5, (index) {
          return Positioned(
            left: 30.0 + (index * 20),
            bottom: 0,
            child:
                Container(
                      width: 20,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.comboFire.withValues(alpha: 0.8),
                            AppColors.comboLegendary.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .moveY(
                      begin: 0,
                      end: -10,
                      duration: 400.ms,
                      curve: Curves.easeInOut,
                    )
                    .fadeOut(duration: 400.ms)
                    .then()
                    .fadeIn(duration: 100.ms),
          );
        }),
      ),
    );
  }
}

/// Floating combo text that appears on correct answers
class FloatingComboText extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onComplete;

  const FloatingComboText({
    super.key,
    required this.text,
    required this.color,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
          text,
          style: AppTextStyles.withGlow(
            AppTextStyles.combo.copyWith(color: color),
            color,
          ),
        )
        .animate(onComplete: (_) => onComplete?.call())
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.2, 1.2),
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .moveY(begin: 0, end: -50, duration: 800.ms, curve: Curves.easeOut)
        .fadeOut(delay: 500.ms, duration: 300.ms);
  }
}

/// Points popup that shows earned points
class PointsPopup extends StatelessWidget {
  final int points;
  final VoidCallback? onComplete;

  const PointsPopup({super.key, required this.points, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Text(
          '+$points',
          style: AppTextStyles.score.copyWith(
            fontSize: 24,
            color: AppColors.accentGold,
          ),
        )
        .animate(onComplete: (_) => onComplete?.call())
        .fadeIn(duration: 100.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 200.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .moveY(begin: 0, end: -30, duration: 500.ms, curve: Curves.easeOut)
        .fadeOut(delay: 300.ms, duration: 200.ms);
  }
}
