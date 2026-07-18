import 'dart:math';

import '../../config/constants/game_constants.dart';

/// One scoring model shared by every memory mode.
class GameScoring {
  const GameScoring._();

  static double comboMultiplier(int streak) {
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
    return 1;
  }

  static int correctColor({required int streak, int difficultyMultiplier = 1}) {
    return (GameConstants.basePointsPerColor *
            max(1, difficultyMultiplier) *
            comboMultiplier(max(0, streak)))
        .round();
  }

  static int roundBonus({
    required int sequenceLength,
    required int difficultyMultiplier,
    int timeRemaining = 0,
    bool perfect = true,
  }) {
    final memoryBonus = max(0, sequenceLength) * 5;
    final speedBonus = max(0, timeRemaining) * 2;
    final perfectBonus = perfect ? GameConstants.perfectSequenceBonus : 0;
    return (memoryBonus + speedBonus + perfectBonus) *
        max(1, difficultyMultiplier);
  }

  static int completedLevel(int level, {int difficultyMultiplier = 1}) {
    return (25 + max(1, level) * 10) * max(1, difficultyMultiplier);
  }
}
