import 'package:echo_memory/core/game/game_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'scoring rewards difficulty, streaks, memory, and speed predictably',
    () {
      expect(GameScoring.correctColor(streak: 0), 10);
      expect(GameScoring.correctColor(streak: 3), 15);
      expect(
        GameScoring.correctColor(streak: 10, difficultyMultiplier: 3),
        150,
      );
      expect(
        GameScoring.roundBonus(
          sequenceLength: 4,
          difficultyMultiplier: 2,
          timeRemaining: 3,
        ),
        152,
      );
      expect(
        GameScoring.roundBonus(
          sequenceLength: 4,
          difficultyMultiplier: 2,
          timeRemaining: -1,
          perfect: false,
        ),
        40,
      );
    },
  );
}
