/// Storage service for Echo Memory
/// Handles all persistent data storage with error resilience
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants/asset_paths.dart';
import '../../data/models/player_stats.dart';
import '../../data/models/power_up.dart';
import '../../data/models/achievement.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize the storage service
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      debugPrint('StorageService init failed: $e');
      _isInitialized = false;
    }
  }

  SharedPreferences? get _preferences {
    if (!_isInitialized || _prefs == null) {
      debugPrint('StorageService not initialized, returning null');
      return null;
    }
    return _prefs;
  }

  // ============ High Scores ============

  Future<int> getHighScore() async {
    try {
      return _preferences?.getInt(AssetPaths.keyHighScore) ?? 0;
    } catch (e) {
      debugPrint('Error getting high score: $e');
      return 0;
    }
  }

  Future<void> setHighScore(int score) async {
    try {
      await _preferences?.setInt(AssetPaths.keyHighScore, score);
    } catch (e) {
      debugPrint('Error setting high score: $e');
    }
  }

  Future<int> getBestStreak() async {
    try {
      return _preferences?.getInt(AssetPaths.keyBestStreak) ?? 0;
    } catch (e) {
      debugPrint('Error getting best streak: $e');
      return 0;
    }
  }

  Future<void> setBestStreak(int streak) async {
    try {
      await _preferences?.setInt(AssetPaths.keyBestStreak, streak);
    } catch (e) {
      debugPrint('Error setting best streak: $e');
    }
  }

  // ============ Player Stats ============

  Future<PlayerStats> getPlayerStats() async {
    try {
      final json = _preferences?.getString(AssetPaths.keyPlayerStats);
      if (json == null) return const PlayerStats();
      return PlayerStats.decode(json);
    } catch (e) {
      debugPrint('Error getting player stats: $e');
      return const PlayerStats();
    }
  }

  Future<void> setPlayerStats(PlayerStats stats) async {
    try {
      await _preferences?.setString(AssetPaths.keyPlayerStats, stats.encode());
    } catch (e) {
      debugPrint('Error setting player stats: $e');
    }
  }

  // ============ Power-Ups ============

  Future<PowerUpInventory> getPowerUps() async {
    try {
      final json = _preferences?.getString(AssetPaths.keyPowerUps);
      if (json == null) return const PowerUpInventory();
      return PowerUpInventory.decode(json);
    } catch (e) {
      debugPrint('Error getting power-ups: $e');
      return const PowerUpInventory();
    }
  }

  Future<void> setPowerUps(PowerUpInventory inventory) async {
    try {
      await _preferences?.setString(AssetPaths.keyPowerUps, inventory.encode());
    } catch (e) {
      debugPrint('Error setting power-ups: $e');
    }
  }

  // ============ Achievements ============

  Future<AchievementProgress> getAchievements() async {
    try {
      final json = _preferences?.getString(AssetPaths.keyAchievements);
      if (json == null) return const AchievementProgress();
      return AchievementProgress.decode(json);
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      return const AchievementProgress();
    }
  }

  Future<void> setAchievements(AchievementProgress progress) async {
    try {
      await _preferences?.setString(
        AssetPaths.keyAchievements,
        progress.encode(),
      );
    } catch (e) {
      debugPrint('Error setting achievements: $e');
    }
  }

  // ============ Daily Challenge ============

  Future<Map<String, dynamic>?> getDailyChallenge() async {
    try {
      final json = _preferences?.getString(AssetPaths.keyDailyChallenge);
      if (json == null) return null;
      return jsonDecode(json);
    } catch (e) {
      debugPrint('Error getting daily challenge: $e');
      return null;
    }
  }

  Future<void> setDailyChallenge(Map<String, dynamic> data) async {
    try {
      await _preferences?.setString(
        AssetPaths.keyDailyChallenge,
        jsonEncode(data),
      );
    } catch (e) {
      debugPrint('Error setting daily challenge: $e');
    }
  }

  // ============ Settings ============

  Future<String> getSelectedTheme() async {
    try {
      return _preferences?.getString(AssetPaths.keySelectedTheme) ?? 'aurora';
    } catch (e) {
      debugPrint('Error getting selected theme: $e');
      return 'aurora';
    }
  }

  Future<void> setSelectedTheme(String theme) async {
    try {
      await _preferences?.setString(AssetPaths.keySelectedTheme, theme);
    } catch (e) {
      debugPrint('Error setting selected theme: $e');
    }
  }

  Future<bool> getSoundEnabled() async {
    try {
      return _preferences?.getBool(AssetPaths.keySoundEnabled) ?? true;
    } catch (e) {
      debugPrint('Error getting sound enabled: $e');
      return true;
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    try {
      await _preferences?.setBool(AssetPaths.keySoundEnabled, enabled);
    } catch (e) {
      debugPrint('Error setting sound enabled: $e');
    }
  }

  Future<bool> getHapticEnabled() async {
    try {
      return _preferences?.getBool(AssetPaths.keyHapticEnabled) ?? true;
    } catch (e) {
      debugPrint('Error getting haptic enabled: $e');
      return true;
    }
  }

  Future<void> setHapticEnabled(bool enabled) async {
    try {
      await _preferences?.setBool(AssetPaths.keyHapticEnabled, enabled);
    } catch (e) {
      debugPrint('Error setting haptic enabled: $e');
    }
  }

  // ============ Utility ============

  /// Clear all stored data (for debugging/reset)
  Future<void> clearAll() async {
    try {
      await _preferences?.clear();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }

  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    try {
      final hasPlayed =
          _preferences?.containsKey(AssetPaths.keyPlayerStats) ?? false;
      return !hasPlayed;
    } catch (e) {
      debugPrint('Error checking first launch: $e');
      return true;
    }
  }
}
