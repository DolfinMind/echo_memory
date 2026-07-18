import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/lumina_controller.dart';

class MatrixGrid extends StatelessWidget {
  final int gridSize;
  final Set<int> activeIndices;
  final Function(int) onTap;
  final LuminaState state;

  const MatrixGrid({
    super.key,
    required this.gridSize,
    required this.activeIndices,
    required this.onTap,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final isActive = activeIndices.contains(index);
          return _MatrixTile(
            isActive: isActive,
            state: state,
            onTap: () => onTap(index),
            index: index,
          );
        },
      ),
    );
  }
}

class _MatrixTile extends StatelessWidget {
  final bool isActive;
  final LuminaState state;
  final VoidCallback onTap;
  final int index;

  const _MatrixTile({
    required this.isActive,
    required this.state,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white.withValues(alpha: 0.05);
    BoxBorder? border = Border.all(color: Colors.white.withValues(alpha: 0.1));
    List<BoxShadow> shadows = [];

    if (isActive) {
      if (state == LuminaState.success) {
        color = AppColors.orbGreen;
        shadows = [
          BoxShadow(
            color: AppColors.orbGreen.withValues(alpha: 0.6),
            blurRadius: 15,
          ),
        ];
      } else if (state == LuminaState.failed) {
        color = AppColors.orbRed;
        shadows = [
          BoxShadow(
            color: AppColors.orbRed.withValues(alpha: 0.6),
            blurRadius: 15,
          ),
        ];
      } else {
        color = AppColors.orbBlue;
        shadows = [
          BoxShadow(
            color: AppColors.orbBlue.withValues(alpha: 0.6),
            blurRadius: 10,
          ),
        ];
      }
      border = null;
    }

    return GestureDetector(
      onTap: onTap,
      child:
          AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: border,
                  boxShadow: shadows,
                ),
              )
              .animate(target: isActive ? 1 : 0)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(0.95, 0.95),
                curve: Curves.easeInOut,
              ),
    );
  }
}
