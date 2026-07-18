import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// A low-cost translucent surface with optional Material press feedback.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.glassBackground,
      borderRadius: radius,
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: borderWidth,
      ),
      boxShadow: boxShadow,
    );

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: onTap == null
            ? DecoratedBox(decoration: decoration, child: content)
            : Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: decoration,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: radius,
                    child: content,
                  ),
                ),
              ),
      ),
    );
  }
}
