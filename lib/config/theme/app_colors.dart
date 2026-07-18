/// App color palette and gradients for Echo Memory
/// A premium, vibrant color system with aurora-inspired themes
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Aurora Gradient
  static const List<Color> auroraGradient = [
    Color(0xFFFF6B6B), // Coral
    Color(0xFF4ECDC4), // Teal
    Color(0xFF45B7D1), // Sky Blue
    Color(0xFF96E6A1), // Mint
  ];

  // Background Gradients
  static const LinearGradient primaryBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1a1a2e), // Deep Navy
      Color(0xFF16213e), // Dark Blue
      Color(0xFF0f3460), // Royal Blue
    ],
  );

  static const LinearGradient gameBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0d0d1a), // Near Black
      Color(0xFF1a1a3a), // Deep Purple Navy
      Color(0xFF252550), // Muted Purple
    ],
  );

  // Game Orb Colors with their glow versions
  static const Color orbRed = Color(0xFFFF6B6B);
  static const Color orbRedGlow = Color(0xFFFF8E8E);
  static const Color orbGreen = Color(0xFF4ECDC4);
  static const Color orbGreenGlow = Color(0xFF7EDFD8);
  static const Color orbBlue = Color(0xFF45B7D1);
  static const Color orbBlueGlow = Color(0xFF74CAE0);
  static const Color orbYellow = Color(0xFFFFE66D);
  static const Color orbYellowGlow = Color(0xFFFFF09D);
  static const Color orbPurple = Color(
    0xFFB794F6,
  ); // Replaced black with purple!
  static const Color orbPurpleGlow = Color(0xFFD4B8FF);

  // Game Orb List (for game logic)
  static const List<Color> gameOrbs = [
    orbRed,
    orbGreen,
    orbBlue,
    orbYellow,
    orbPurple,
  ];

  static const List<Color> gameOrbGlows = [
    orbRedGlow,
    orbGreenGlow,
    orbBlueGlow,
    orbYellowGlow,
    orbPurpleGlow,
  ];

  // UI Colors
  static const Color surface = Color(0xFF1E1E2E);
  static const Color surfaceLight = Color(0xFF2A2A3E);
  static const Color cardBackground = Color(0x20FFFFFF);
  static const Color cardBorder = Color(0x40FFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0x80FFFFFF); // 50% white

  // Accent Colors
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentSuccess = Color(0xFF4ECDC4);
  static const Color accentError = Color(0xFFFF6B6B);
  static const Color accentWarning = Color(0xFFFFE66D);

  // Combo Colors (for streak effects)
  static const Color comboGood = Color(0xFF4ECDC4); // 3-streak
  static const Color comboAmazing = Color(0xFF45B7D1); // 5-streak
  static const Color comboFire = Color(0xFFFF6B6B); // 7-streak
  static const Color comboLegendary = Color(0xFFFFD700); // 10-streak

  // Glassmorphism
  static Color glassBackground = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);

  // Power-up Colors
  static const Color powerUpSlowMo = Color(0xFF45B7D1);
  static const Color powerUpHint = Color(0xFFFFE66D);
  static const Color powerUpShield = Color(0xFF4ECDC4);
  static const Color powerUpFreeze = Color(0xFFB794F6);
  static const Color powerUpDouble = Color(0xFFFF6B6B);

  // Theme Gradients for unlockable themes
  static const Map<String, List<Color>> themeGradients = {
    'aurora': auroraGradient,
    'neon': [Color(0xFFFF00FF), Color(0xFF00FFFF), Color(0xFF00FF00)],
    'ocean': [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF90E0EF)],
    'space': [Color(0xFF2D1B69), Color(0xFF11998E), Color(0xFF38EF7D)],
    'retro': [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)],
  };

  // Difficulty Colors
  static const Color difficultyBeginner = Color(0xFF4ECDC4);
  static const Color difficultyExpert = Color(0xFFFF9F43);
  static const Color difficultyMaster = Color(0xFFFF6B6B);

  // Get gradient for orb (radial glow effect)
  static RadialGradient getOrbGradient(int index) {
    final color = gameOrbs[index % gameOrbs.length];
    final glowColor = gameOrbGlows[index % gameOrbGlows.length];
    return RadialGradient(
      colors: [glowColor, color, color.withValues(alpha: 0.8)],
      stops: const [0.0, 0.4, 1.0],
    );
  }
}
