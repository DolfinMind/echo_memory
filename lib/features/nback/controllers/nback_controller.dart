import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../core/game/game_scoring.dart';

enum ReflexState { ready, showing, waiting, feedback, gameOver }

class ReflexCard {
  final int colorIndex;
  final int shapeIndex;

  ReflexCard(this.colorIndex, this.shapeIndex);

  bool matches(ReflexCard other) =>
      colorIndex == other.colorIndex && shapeIndex == other.shapeIndex;
}

class ReflexController extends ChangeNotifier {
  int score = 0;
  int streak = 0;
  int round = 0;
  int lives = 3;

  ReflexState _state = ReflexState.ready;
  ReflexCard? _previousCard;
  ReflexCard? _currentCard;
  bool? _lastAnswerCorrect;
  bool _shouldMatch = false; // Was the answer supposed to be "Same"?
  int _lastAward = 0;
  Timer? _advanceTimer;

  final Random _random = Random();

  ReflexState get state => _state;
  ReflexCard? get currentCard => _currentCard;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;
  bool get isFirstCard => _previousCard == null;
  int get lastAward => _lastAward;

  void startGame() {
    _advanceTimer?.cancel();
    score = 0;
    streak = 0;
    round = 0;
    lives = 3;
    _previousCard = null;
    _currentCard = null;
    _lastAward = 0;
    _state = ReflexState.ready;
    notifyListeners();
  }

  void showNextCard() {
    round++;
    _previousCard = _currentCard;

    // 40% chance to match previous card (if exists)
    if (_previousCard != null && _random.nextDouble() < 0.4) {
      _currentCard = ReflexCard(
        _previousCard!.colorIndex,
        _previousCard!.shapeIndex,
      );
      _shouldMatch = true;
    } else {
      _currentCard = ReflexCard(_random.nextInt(6), _random.nextInt(5));
      _shouldMatch =
          _previousCard != null && _currentCard!.matches(_previousCard!);
    }

    _lastAnswerCorrect = null;
    _lastAward = 0;
    _state = ReflexState.waiting;
    notifyListeners();
  }

  void answerSame() => _checkAnswer(true);
  void answerDifferent() => _checkAnswer(false);

  void _checkAnswer(bool userSaidSame) {
    if (_state != ReflexState.waiting) return;

    bool correct = (userSaidSame == _shouldMatch);
    _lastAnswerCorrect = correct;

    if (correct) {
      streak++;
      _lastAward = GameScoring.correctColor(streak: streak);
      score += _lastAward;
      // Auto-continue on correct - just show next card immediately
      // We'll briefly flash the result in UI but stay in flow
      notifyListeners(); // Flash feedback
      _advanceTimer?.cancel();
      _advanceTimer = Timer(const Duration(milliseconds: 400), () {
        if (lives > 0) showNextCard();
      });
    } else {
      streak = 0;
      lives--;
      _state = lives > 0 ? ReflexState.feedback : ReflexState.gameOver;
      notifyListeners();
    }
  }

  void continueGame() {
    if (_state == ReflexState.feedback) {
      showNextCard();
    }
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }
}
