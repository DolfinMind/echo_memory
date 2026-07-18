import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/stream_controller.dart';

class StreamItemWidget extends StatelessWidget {
  final StreamItem item;
  final double size;

  const StreamItemWidget({super.key, required this.item, this.size = 60});

  static const List<Color> colors = [
    AppColors.orbRed,
    AppColors.orbBlue,
    AppColors.orbGreen,
    AppColors.orbYellow,
    AppColors.orbPurple,
    Color(0xFFFF9F43), // Orange
  ];

  static const List<IconData> shapes = [
    LucideIcons.circle,
    LucideIcons.square,
    LucideIcons.triangle,
    LucideIcons.star,
    LucideIcons.heart,
  ];

  @override
  Widget build(BuildContext context) {
    final color = colors[item.colorIndex];
    final shape = shapes[item.shapeIndex];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(shape, color: color, size: size * 0.5),
    );
  }
}
