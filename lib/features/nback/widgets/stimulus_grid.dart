import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';

class StimulusGrid extends StatelessWidget {
  final int? activePosition;
  final Color? activeColor;
  final bool showStimulus;

  const StimulusGrid({
    super.key,
    this.activePosition,
    this.activeColor,
    this.showStimulus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final isActive = showStimulus && activePosition == index;
          return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive
                      ? (activeColor ?? AppColors.orbBlue)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? (activeColor ?? AppColors.orbBlue).withValues(
                            alpha: 0.8,
                          )
                        : Colors.white.withValues(alpha: 0.1),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: (activeColor ?? AppColors.orbBlue)
                                .withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              )
              .animate(target: isActive ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(0.9, 0.9));
        },
      ),
    );
  }
}
