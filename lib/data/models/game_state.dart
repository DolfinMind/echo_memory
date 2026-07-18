/// Game state model for Echo Memory
/// Tracks all game-related state during gameplay
library;

import 'package:flutter/material.dart';

enum GameStatus {
  idle,
  showingPattern,
  waitingForInput,
  levelComplete,
  gameOver,
  paused,
}

class GameState {
  final List<Color> sequence;
  final int currentIndex;
  final GameStatus status;
  final int score;
  final int lives;
  final int level;
  final int timeRemaining;
  final int currentStreak;
  final int bestStreak;
  final int comboLevel;
  final double multiplier;
  final String? activePowerUp;
  final bool isPaused;
  final DateTime startTime;

  const GameState({
    this.sequence = const [],
    this.currentIndex = 0,
    this.status = GameStatus.idle,
    this.score = 0,
    this.lives = 3,
    this.level = 1,
    this.timeRemaining = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.comboLevel = 0,
    this.multiplier = 1.0,
    this.activePowerUp,
    this.isPaused = false,
    DateTime? startTime,
  }) : startTime = startTime ?? const _DefaultDateTime();

  GameState copyWith({
    List<Color>? sequence,
    int? currentIndex,
    GameStatus? status,
    int? score,
    int? lives,
    int? level,
    int? timeRemaining,
    int? currentStreak,
    int? bestStreak,
    int? comboLevel,
    double? multiplier,
    String? activePowerUp,
    bool? isPaused,
    DateTime? startTime,
  }) {
    return GameState(
      sequence: sequence ?? this.sequence,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      level: level ?? this.level,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      comboLevel: comboLevel ?? this.comboLevel,
      multiplier: multiplier ?? this.multiplier,
      activePowerUp: activePowerUp ?? this.activePowerUp,
      isPaused: isPaused ?? this.isPaused,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Check if all colors in the sequence have been correctly selected
  bool get isSequenceComplete => currentIndex >= sequence.length;

  /// Get the current color to select
  Color? get currentTargetColor =>
      currentIndex < sequence.length ? sequence[currentIndex] : null;

  /// Get progress as a percentage
  double get progress => sequence.isEmpty ? 0 : currentIndex / sequence.length;

  /// Get combo text based on current streak
  String? get comboText {
    if (currentStreak >= 10) return 'LEGENDARY!';
    if (currentStreak >= 7) return 'ON FIRE!';
    if (currentStreak >= 5) return 'AMAZING!';
    if (currentStreak >= 3) return 'GOOD!';
    return null;
  }

  /// Calculate score for correct answer with multiplier
  int calculatePointsForCorrect(int basePoints) {
    return (basePoints * multiplier).round();
  }

  static GameState initial({int lives = 3}) {
    return GameState(lives: lives, startTime: DateTime.now());
  }
}

/// Default DateTime implementation for const constructor
class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}
