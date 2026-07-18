import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

/// A tactile primary action that keeps the neon palette without idle animation.
class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final double width;
  final double height;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppColors.orbBlue,
    this.width = 200,
    this.height = 56,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final callback = isDisabled || isLoading ? null : onPressed;
    final content = isLoading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: callback != null,
      label: text,
      child: SizedBox(
        width: width,
        height: height.clamp(48, double.infinity),
        child: FilledButton(
          onPressed: callback,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.surfaceLight,
            disabledForegroundColor: AppColors.textMuted,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
