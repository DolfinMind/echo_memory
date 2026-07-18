import 'package:echo_memory/data/models/player_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first zero-score game is recorded without missing-map crashes', () {
    final result = const PlayerStats().recordGame(
      score: 0,
      streak: 0,
      sequenceLength: 5,
      correctAnswers: 0,
      mistakes: 1,
      playTime: const Duration(seconds: 10),
      gameMode: 'classic',
      difficulty: 'master',
    );

    expect(result.totalGamesPlayed, 1);
    expect(result.modeHighScores['classic'], 0);
    expect(result.difficultyHighScores['master'], 0);
  });
}
