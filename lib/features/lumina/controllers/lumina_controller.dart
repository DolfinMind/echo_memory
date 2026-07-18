import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../core/game/game_scoring.dart';

enum LuminaState {
  watching, // Pattern is being displayed
  playing, // User is recalling
  success, // Round complete
  failed, // Wrong tile tapped
}

class LuminaGameController extends ChangeNotifier {
  int level = 1;
  int gridSize = 3;
  int score = 0;

  LuminaState _state = LuminaState.watching;
  final Set<int> _currentPattern = {};
  final Set<int> _userPattern = {};

  LuminaState get state => _state;
  Set<int> get activePattern =>
      _state == LuminaState.watching ? _currentPattern : _userPattern;

  void startGame() {
    level = 1;
    score = 0;
    gridSize = 3;
    _generateLevel();
  }

  void _generateLevel() {
    // Determine grid size based on level
    if (level >= 4) gridSize = 4;
    if (level >= 7) gridSize = 5;

    // Pattern length increases with level
    int patternLength = 3 + (level ~/ 2);
    patternLength = min(
      patternLength,
      (gridSize * gridSize) ~/ 2,
    ); // Cap at 50% fill

    _currentPattern.clear();
    _userPattern.clear();

    final random = Random();
    while (_currentPattern.length < patternLength) {
      _currentPattern.add(random.nextInt(gridSize * gridSize));
    }

    _state = LuminaState.watching;
    notifyListeners();
  }

  void startRecall() {
    _state = LuminaState.playing;
    notifyListeners();
  }

  bool handleTap(int index) {
    if (_state != LuminaState.playing) return false;

    // Check if tile is part of pattern
    if (_currentPattern.contains(index)) {
      if (!_userPattern.contains(index)) {
        _userPattern.add(index);

        // Check if pattern complete
        if (_userPattern.length == _currentPattern.length) {
          _state = LuminaState.success;
          score += GameScoring.completedLevel(level);
          notifyListeners();
          return true; // Complete
        }
        notifyListeners();
      }
      return true; // Correct tap
    } else {
      _state = LuminaState.failed;
      notifyListeners();
      return false; // Wrong tap
    }
  }

  void nextRound() {
    level++;
    _generateLevel();
  }

  void retry() {
    // Reset pattern but same level
    _currentPattern.clear();
    _userPattern.clear();
    _generateLevel();
  }
}
