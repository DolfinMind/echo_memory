/// Player statistics model for Echo Memory
/// Persistent player progress and achievements tracking
library;

import 'dart:convert';
import 'dart:math';

class PlayerStats {
  final int totalGamesPlayed;
  final int totalScore;
  final int highScore;
  final int bestStreak;
  final int longestSequence;
  final int totalCorrectAnswers;
  final int totalMistakes;
  final int dailyChallengesCompleted;
  final int dailyChallengeStreak;
  final int powerUpsUsed;
  final Map<String, int> modeHighScores;
  final Map<String, int> difficultyHighScores;
  final DateTime? lastPlayedDate;
  final DateTime? firstPlayedDate;
  final Duration totalPlayTime;

  const PlayerStats({
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.highScore = 0,
    this.bestStreak = 0,
    this.longestSequence = 0,
    this.totalCorrectAnswers = 0,
    this.totalMistakes = 0,
    this.dailyChallengesCompleted = 0,
    this.dailyChallengeStreak = 0,
    this.powerUpsUsed = 0,
    this.modeHighScores = const {},
    this.difficultyHighScores = const {},
    this.lastPlayedDate,
    this.firstPlayedDate,
    this.totalPlayTime = Duration.zero,
  });

  PlayerStats copyWith({
    int? totalGamesPlayed,
    int? totalScore,
    int? highScore,
    int? bestStreak,
    int? longestSequence,
    int? totalCorrectAnswers,
    int? totalMistakes,
    int? dailyChallengesCompleted,
    int? dailyChallengeStreak,
    int? powerUpsUsed,
    Map<String, int>? modeHighScores,
    Map<String, int>? difficultyHighScores,
    DateTime? lastPlayedDate,
    DateTime? firstPlayedDate,
    Duration? totalPlayTime,
  }) {
    return PlayerStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      highScore: highScore ?? this.highScore,
      bestStreak: bestStreak ?? this.bestStreak,
      longestSequence: longestSequence ?? this.longestSequence,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
      dailyChallengeStreak: dailyChallengeStreak ?? this.dailyChallengeStreak,
      powerUpsUsed: powerUpsUsed ?? this.powerUpsUsed,
      modeHighScores: modeHighScores ?? this.modeHighScores,
      difficultyHighScores: difficultyHighScores ?? this.difficultyHighScores,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      firstPlayedDate: firstPlayedDate ?? this.firstPlayedDate,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
    );
  }

  /// Calculate accuracy percentage
  double get accuracy {
    final total = totalCorrectAnswers + totalMistakes;
    if (total == 0) return 0;
    return (totalCorrectAnswers / total) * 100;
  }

  /// Get average score per game
  double get averageScore {
    if (totalGamesPlayed == 0) return 0;
    return totalScore / totalGamesPlayed;
  }

  /// Get player level based on total score
  int get playerLevel {
    return (totalScore / 1000).floor() + 1;
  }

  /// Get progress to next level (0.0 - 1.0)
  double get levelProgress {
    return (totalScore % 1000) / 1000;
  }

  /// Get total days played
  int get daysPlayed {
    if (firstPlayedDate == null) return 0;
    return DateTime.now().difference(firstPlayedDate!).inDays + 1;
  }

  /// Update stats after a game
  PlayerStats recordGame({
    required int score,
    required int streak,
    required int sequenceLength,
    required int correctAnswers,
    required int mistakes,
    required Duration playTime,
    String? gameMode,
    String? difficulty,
  }) {
    final newModeHighScores = Map<String, int>.from(modeHighScores);
    if (gameMode != null) {
      newModeHighScores[gameMode] = max(
        newModeHighScores[gameMode] ?? 0,
        score,
      );
    }

    final newDifficultyHighScores = Map<String, int>.from(difficultyHighScores);
    if (difficulty != null) {
      newDifficultyHighScores[difficulty] = max(
        newDifficultyHighScores[difficulty] ?? 0,
        score,
      );
    }

    return copyWith(
      totalGamesPlayed: totalGamesPlayed + 1,
      totalScore: totalScore + score,
      highScore: score > highScore ? score : null,
      bestStreak: streak > bestStreak ? streak : null,
      longestSequence: sequenceLength > longestSequence ? sequenceLength : null,
      totalCorrectAnswers: totalCorrectAnswers + correctAnswers,
      totalMistakes: totalMistakes + mistakes,
      modeHighScores: newModeHighScores,
      difficultyHighScores: newDifficultyHighScores,
      lastPlayedDate: DateTime.now(),
      firstPlayedDate: firstPlayedDate ?? DateTime.now(),
      totalPlayTime: totalPlayTime + playTime,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'highScore': highScore,
      'bestStreak': bestStreak,
      'longestSequence': longestSequence,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalMistakes': totalMistakes,
      'dailyChallengesCompleted': dailyChallengesCompleted,
      'dailyChallengeStreak': dailyChallengeStreak,
      'powerUpsUsed': powerUpsUsed,
      'modeHighScores': modeHighScores,
      'difficultyHighScores': difficultyHighScores,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'firstPlayedDate': firstPlayedDate?.toIso8601String(),
      'totalPlayTimeSeconds': totalPlayTime.inSeconds,
    };
  }

  /// Create from JSON
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      highScore: json['highScore'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      longestSequence: json['longestSequence'] ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      totalMistakes: json['totalMistakes'] ?? 0,
      dailyChallengesCompleted: json['dailyChallengesCompleted'] ?? 0,
      dailyChallengeStreak: json['dailyChallengeStreak'] ?? 0,
      powerUpsUsed: json['powerUpsUsed'] ?? 0,
      modeHighScores: Map<String, int>.from(json['modeHighScores'] ?? {}),
      difficultyHighScores: Map<String, int>.from(
        json['difficultyHighScores'] ?? {},
      ),
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
      firstPlayedDate: json['firstPlayedDate'] != null
          ? DateTime.parse(json['firstPlayedDate'])
          : null,
      totalPlayTime: Duration(seconds: json['totalPlayTimeSeconds'] ?? 0),
    );
  }

  /// Encode to string for storage
  String encode() => jsonEncode(toJson());

  /// Decode from string
  factory PlayerStats.decode(String source) {
    return PlayerStats.fromJson(jsonDecode(source));
  }
}
