/// Achievement model for Echo Memory
/// Defines achievements, badges, and unlockables
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/theme/app_colors.dart';

enum AchievementRarity { bronze, silver, gold, platinum, diamond }

enum AchievementCategory { gameplay, streak, score, daily, special }

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementRarity rarity;
  final AchievementCategory category;
  final int requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String? reward; // Theme name or power-up type

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.category,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
    this.reward,
  });

  Achievement unlock() {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      rarity: rarity,
      category: category,
      requirement: requirement,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      reward: reward,
    );
  }

  /// Get color based on rarity
  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:
        return AppColors.accentGold;
      case AchievementRarity.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementRarity.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  /// Get gradient for achievement card
  LinearGradient get rarityGradient {
    switch (rarity) {
      case AchievementRarity.bronze:
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
        );
      case AchievementRarity.silver:
        return const LinearGradient(
          colors: [Color(0xFFE8E8E8), Color(0xFFA0A0A0)],
        );
      case AchievementRarity.gold:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
        );
      case AchievementRarity.platinum:
        return const LinearGradient(
          colors: [Color(0xFFE5E4E2), Color(0xFFADADAD)],
        );
      case AchievementRarity.diamond:
        return const LinearGradient(
          colors: [Color(0xFFB9F2FF), Color(0xFF87CEEB)],
        );
    }
  }

  /// All achievements
  static List<Achievement> get allAchievements => [
    // Gameplay Achievements
    const Achievement(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Complete your first game',
      icon: LucideIcons.flag,
      rarity: AchievementRarity.bronze,
      category: AchievementCategory.gameplay,
      requirement: 1,
    ),
    const Achievement(
      id: 'getting_started',
      name: 'Getting Started',
      description: 'Play 10 games',
      icon: LucideIcons.play,
      rarity: AchievementRarity.bronze,
      category: AchievementCategory.gameplay,
      requirement: 10,
    ),
    const Achievement(
      id: 'dedicated_player',
      name: 'Dedicated Player',
      description: 'Play 50 games',
      icon: LucideIcons.gamepad2,
      rarity: AchievementRarity.silver,
      category: AchievementCategory.gameplay,
      requirement: 50,
    ),
    const Achievement(
      id: 'veteran',
      name: 'Veteran',
      description: 'Play 100 games',
      icon: LucideIcons.medal,
      rarity: AchievementRarity.gold,
      category: AchievementCategory.gameplay,
      requirement: 100,
    ),

    // Streak Achievements
    const Achievement(
      id: 'on_a_roll',
      name: 'On a Roll',
      description: 'Get a 5-streak',
      icon: LucideIcons.flame,
      rarity: AchievementRarity.bronze,
      category: AchievementCategory.streak,
      requirement: 5,
    ),
    const Achievement(
      id: 'hot_streak',
      name: 'Hot Streak',
      description: 'Get a 10-streak',
      icon: LucideIcons.flame,
      rarity: AchievementRarity.silver,
      category: AchievementCategory.streak,
      requirement: 10,
    ),
    const Achievement(
      id: 'streak_king',
      name: 'Streak King',
      description: 'Get a 15-streak',
      icon: LucideIcons.sparkles,
      rarity: AchievementRarity.gold,
      category: AchievementCategory.streak,
      requirement: 15,
      reward: 'crown_icon',
    ),
    const Achievement(
      id: 'unstoppable',
      name: 'Unstoppable',
      description: 'Get a 25-streak',
      icon: LucideIcons.zap,
      rarity: AchievementRarity.diamond,
      category: AchievementCategory.streak,
      requirement: 25,
    ),

    // Score Achievements
    const Achievement(
      id: 'score_100',
      name: 'Point Scorer',
      description: 'Score 100 points in a game',
      icon: LucideIcons.star,
      rarity: AchievementRarity.bronze,
      category: AchievementCategory.score,
      requirement: 100,
    ),
    const Achievement(
      id: 'score_500',
      name: 'High Scorer',
      description: 'Score 500 points in a game',
      icon: LucideIcons.trendingUp,
      rarity: AchievementRarity.silver,
      category: AchievementCategory.score,
      requirement: 500,
    ),
    const Achievement(
      id: 'score_1000',
      name: 'Score Master',
      description: 'Score 1000 points in a game',
      icon: LucideIcons.trophy,
      rarity: AchievementRarity.gold,
      category: AchievementCategory.score,
      requirement: 1000,
    ),
    const Achievement(
      id: 'score_5000',
      name: 'Legendary Score',
      description: 'Score 5000 points in a game',
      icon: LucideIcons.award,
      rarity: AchievementRarity.diamond,
      category: AchievementCategory.score,
      requirement: 5000,
    ),

    // Daily Achievements
    const Achievement(
      id: 'daily_first',
      name: 'Daily Challenger',
      description: 'Complete your first daily challenge',
      icon: LucideIcons.calendar,
      rarity: AchievementRarity.bronze,
      category: AchievementCategory.daily,
      requirement: 1,
    ),
    const Achievement(
      id: 'daily_week',
      name: 'Perfect Week',
      description: 'Complete 7 daily challenges in a row',
      icon: LucideIcons.calendarDays,
      rarity: AchievementRarity.gold,
      category: AchievementCategory.daily,
      requirement: 7,
      reward: 'gold_theme',
    ),
    const Achievement(
      id: 'daily_month',
      name: 'Monthly Master',
      description: 'Complete 30 daily challenges',
      icon: LucideIcons.calendarCheck,
      rarity: AchievementRarity.platinum,
      category: AchievementCategory.daily,
      requirement: 30,
    ),

    // Special Achievements
    const Achievement(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete a sequence in under 2 seconds',
      icon: LucideIcons.gauge,
      rarity: AchievementRarity.silver,
      category: AchievementCategory.special,
      requirement: 2,
    ),
    const Achievement(
      id: 'memory_master',
      name: 'Memory Master',
      description: 'Remember a 20-color sequence',
      icon: LucideIcons.brain,
      rarity: AchievementRarity.platinum,
      category: AchievementCategory.special,
      requirement: 20,
    ),
    const Achievement(
      id: 'untouchable',
      name: 'Untouchable',
      description: 'Complete Master difficulty without losing a life',
      icon: LucideIcons.shield,
      rarity: AchievementRarity.diamond,
      category: AchievementCategory.special,
      requirement: 1,
    ),
    const Achievement(
      id: 'perfectionist',
      name: 'Perfectionist',
      description: 'Achieve 100% accuracy in 10 games',
      icon: LucideIcons.badgeCheck,
      rarity: AchievementRarity.gold,
      category: AchievementCategory.special,
      requirement: 10,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (merges with static definition)
  factory Achievement.fromJson(Map<String, dynamic> json) {
    final base = getById(json['id']);
    if (base == null) {
      throw ArgumentError('Unknown achievement ID: ${json['id']}');
    }
    return Achievement(
      id: base.id,
      name: base.name,
      description: base.description,
      icon: base.icon,
      rarity: base.rarity,
      category: base.category,
      requirement: base.requirement,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      reward: base.reward,
    );
  }
}

/// Player's achievement progress
class AchievementProgress {
  final Map<String, bool> unlocked;
  final Map<String, DateTime> unlockedDates;

  const AchievementProgress({
    this.unlocked = const {},
    this.unlockedDates = const {},
  });

  bool isUnlocked(String id) => unlocked[id] ?? false;

  int get totalUnlocked => unlocked.values.where((v) => v).length;

  double get completionPercentage {
    if (Achievement.allAchievements.isEmpty) return 0;
    return totalUnlocked / Achievement.allAchievements.length;
  }

  AchievementProgress unlock(String id) {
    final newUnlocked = Map<String, bool>.from(unlocked);
    final newDates = Map<String, DateTime>.from(unlockedDates);
    newUnlocked[id] = true;
    newDates[id] = DateTime.now();
    return AchievementProgress(unlocked: newUnlocked, unlockedDates: newDates);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unlocked': unlocked,
      'unlockedDates': unlockedDates.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  /// Create from JSON
  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    final unlockedDates = <String, DateTime>{};
    (json['unlockedDates'] as Map<String, dynamic>?)?.forEach((key, value) {
      unlockedDates[key] = DateTime.parse(value);
    });
    return AchievementProgress(
      unlocked: Map<String, bool>.from(json['unlocked'] ?? {}),
      unlockedDates: unlockedDates,
    );
  }

  /// Encode to string
  String encode() => jsonEncode(toJson());

  /// Decode from string
  factory AchievementProgress.decode(String source) {
    return AchievementProgress.fromJson(jsonDecode(source));
  }
}
