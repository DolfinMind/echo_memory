/// App typography system for Echo Memory
/// Modern, clean font styles with responsive sizing
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Font Family
  static const String fontFamily = 'Roboto';

  // Display Styles (for titles and headers)
  static TextStyle displayLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle displayMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displaySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Headline Styles
  static TextStyle headlineLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headlineSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Title Styles
  static TextStyle titleLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle titleMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle titleSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Styles
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // Label Styles
  static TextStyle labelLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Special Styles
  static TextStyle score = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.accentGold,
    letterSpacing: 2,
    shadows: [
      Shadow(color: Color(0x80FFD700), blurRadius: 20, offset: Offset(0, 0)),
    ],
  );

  static TextStyle combo = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1,
  );

  static TextStyle timer = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle timerCritical = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.accentError,
  );

  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  // Shadow text (for game title with glow)
  static TextStyle gameTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 52,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -1,
    shadows: [
      Shadow(
        color: AppColors.orbBlue.withValues(alpha: 0.5),
        blurRadius: 20,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: AppColors.orbPurple.withValues(alpha: 0.3),
        blurRadius: 40,
        offset: const Offset(0, 0),
      ),
    ],
  );

  // Get responsive text style
  static TextStyle responsive(TextStyle base, double scaleFactor) {
    return base.copyWith(fontSize: (base.fontSize ?? 14) * scaleFactor);
  }

  // Get colored version of any style
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  // Get glowing version of any style
  static TextStyle withGlow(TextStyle base, Color glowColor) {
    return base.copyWith(
      shadows: [
        Shadow(
          color: glowColor.withValues(alpha: 0.6),
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }
}
