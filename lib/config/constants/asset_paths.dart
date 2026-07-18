/// Asset path constants for Echo Memory
/// Centralized asset management
class AssetPaths {
  AssetPaths._();

  // Sound Effects
  static const String soundsPath = 'assets/sounds/';

  static const String soundColorRed = '${soundsPath}color_red.mp3';
  static const String soundColorGreen = '${soundsPath}color_green.mp3';
  static const String soundColorBlue = '${soundsPath}color_blue.mp3';
  static const String soundColorYellow = '${soundsPath}color_yellow.mp3';
  static const String soundColorPurple =
      '${soundsPath}color_purple.mp3'; // New!

  static const String soundCorrect = '${soundsPath}correct.mp3';
  static const String soundWrong = '${soundsPath}wrong.mp3';
  static const String soundVictory = '${soundsPath}victory.mp3';
  static const String soundGameOver = '${soundsPath}game_over.mp3';
  static const String soundCombo = '${soundsPath}combo.mp3';
  static const String soundPowerUp = '${soundsPath}power_up.mp3';
  static const String soundLevelUp = '${soundsPath}level_up.mp3';
  static const String soundAchievement = '${soundsPath}achievement.mp3';

  // Color sound list (indexed with game orbs)
  static const List<String> colorSounds = [
    'color_red.mp3',
    'color_green.mp3',
    'color_blue.mp3',
    'color_yellow.mp3',
    'color_purple.mp3', // Replaced black
  ];

  // Images
  static const String imagesPath = 'assets/images/';

  // Icons
  static const String iconsPath = 'assets/icons/';

  // Animations (Lottie)
  static const String animationsPath = 'assets/animations/';
  static const String animConfetti = '${animationsPath}confetti.json';
  static const String animFireworks = '${animationsPath}fireworks.json';
  static const String animStar = '${animationsPath}star.json';
  static const String animHeart = '${animationsPath}heart.json';

  // Storage Keys
  static const String keyHighScore = 'high_score';
  static const String keyBestStreak = 'best_streak';
  static const String keyTotalGamesPlayed = 'total_games_played';
  static const String keyAchievements = 'achievements';
  static const String keyDailyChallenge = 'daily_challenge';
  static const String keySelectedTheme = 'selected_theme';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyHapticEnabled = 'haptic_enabled';
  static const String keyPowerUps = 'power_ups';
  static const String keyPlayerStats = 'player_stats';
}
