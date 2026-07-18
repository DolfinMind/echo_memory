import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../core/game/game_scoring.dart';

enum StreamState { ready, flowing, hidden, recall, feedback, levelComplete }

enum StreamDifficulty { color, shape, both }

class StreamItem {
  final int shapeIndex; // 0-4
  final int colorIndex; // 0-5

  const StreamItem({required this.shapeIndex, required this.colorIndex});

  @override
  bool operator ==(Object other) =>
      other is StreamItem &&
      shapeIndex == other.shapeIndex &&
      colorIndex == other.colorIndex;

  @override
  int get hashCode => shapeIndex.hashCode ^ colorIndex.hashCode;

  StreamItem copyWith({int? shapeIndex, int? colorIndex}) => StreamItem(
    shapeIndex: shapeIndex ?? this.shapeIndex,
    colorIndex: colorIndex ?? this.colorIndex,
  );
}

class StreamController extends ChangeNotifier {
  int level = 1;
  int score = 0;
  int lives = 3;
  StreamDifficulty difficulty = StreamDifficulty.both;

  StreamState _state =
      StreamState.ready; // Start with ready to choose difficulty
  final List<StreamItem> _streamItems = [];
  StreamItem? _hiddenItem;
  int _hiddenIndex = 0;
  List<StreamItem> _choices = [];

  StreamState get state => _state;
  List<StreamItem> get streamItems => List.unmodifiable(_streamItems);
  StreamItem? get hiddenItem => _hiddenItem;
  int get hiddenIndex => _hiddenIndex;
  List<StreamItem> get choices => List.unmodifiable(_choices);

  final Random _random = Random();

  int get itemCount => min(3 + (level ~/ 2), 7);
  Duration get flowSpeed =>
      Duration(milliseconds: max(800, 1600 - (level * 100)));

  void setDifficulty(StreamDifficulty diff) {
    difficulty = diff;
    startGame();
  }

  void startGame() {
    level = 1;
    score = 0;
    lives = 3;
    _generateStream();
  }

  void _generateStream() {
    _streamItems.clear();
    final Set<String> usedCombos = {};

    // Fixed attributes for single-mode difficulties
    final fixedShape = _random.nextInt(5); // e.g. always Circle for Color mode
    final fixedColor = _random.nextInt(6); // e.g. always Blue for Shape mode

    while (_streamItems.length < itemCount) {
      int shape = 0;
      int color = 0;

      switch (difficulty) {
        case StreamDifficulty.color:
          shape = fixedShape;
          color = _random.nextInt(6);
          break;
        case StreamDifficulty.shape:
          shape = _random.nextInt(5);
          color = fixedColor;
          break;
        case StreamDifficulty.both:
          shape = _random.nextInt(5);
          color = _random.nextInt(6);
          break;
      }

      // Ensure adjacent items are different to make "flow" distinct
      // If we allow duplicates, just ensure instant back-to-back isn't confusing
      // But distinct items are better for recall tasks
      final key = '${shape}_$color';

      // Try to keep items unique within the stream for clarity
      if (!usedCombos.contains(key)) {
        usedCombos.add(key);
        _streamItems.add(StreamItem(shapeIndex: shape, colorIndex: color));
      } else if (usedCombos.length >=
          (difficulty == StreamDifficulty.both ? 30 : 5)) {
        // If we exhausted unique combos (unlikely), allow dupes
        _streamItems.add(StreamItem(shapeIndex: shape, colorIndex: color));
      }
    }

    _state = StreamState.flowing;
    notifyListeners();
  }

  void hideItems() {
    _hiddenIndex = _random.nextInt(_streamItems.length);
    _hiddenItem = _streamItems[_hiddenIndex];

    final Set<StreamItem> choiceSet = {_hiddenItem!};

    // Logic for generating valid distractors based on difficulty
    int attempts = 0;
    while (choiceSet.length < 4 && attempts < 100) {
      attempts++;
      int s = 0, c = 0;

      // Inherit fixed properties to make distractions valid
      switch (difficulty) {
        case StreamDifficulty.color:
          s = _hiddenItem!.shapeIndex; // Same shape
          c = _random.nextInt(6); // Diff color
          break;
        case StreamDifficulty.shape:
          s = _random.nextInt(5); // Diff shape
          c = _hiddenItem!.colorIndex; // Same color
          break;
        case StreamDifficulty.both:
          s = _random.nextInt(5);
          c = _random.nextInt(6);
          break;
      }

      final fake = StreamItem(shapeIndex: s, colorIndex: c);
      choiceSet.add(fake);
    }

    _choices = choiceSet.toList()..shuffle();
    _state = StreamState.recall;
    notifyListeners();
  }

  bool selectAnswer(StreamItem selected) {
    if (_state != StreamState.recall) return false;

    bool correct = selected == _hiddenItem;

    if (correct) {
      score += GameScoring.completedLevel(
        level,
        difficultyMultiplier: difficulty == StreamDifficulty.both ? 2 : 1,
      );
      _state = StreamState.levelComplete;
    } else {
      lives--;
      _state = StreamState.feedback;
    }

    notifyListeners();
    return correct;
  }

  void nextLevel() {
    level++;
    _generateStream();
  }

  void retry() {
    _generateStream();
  }

  void resetGame() {
    _state = StreamState.ready;
    notifyListeners();
  }

  bool get isGameOver => lives <= 0;
}
