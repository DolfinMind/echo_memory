/// Tutorial Service for Echo Memory
/// Manages tutorial completion state persistence
library;

import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _prefix = 'tutorial_seen_';

  static TutorialService? _instance;
  SharedPreferences? _prefs;

  TutorialService._();

  static Future<TutorialService> getInstance() async {
    if (_instance == null) {
      _instance = TutorialService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// Check if user has seen the tutorial for a specific game mode
  bool hasSeenTutorial(String gameMode) {
    return _prefs?.getBool('$_prefix$gameMode') ?? false;
  }

  /// Mark tutorial as complete for a game mode
  Future<void> markTutorialComplete(String gameMode) async {
    await _prefs?.setBool('$_prefix$gameMode', true);
  }

  /// Reset tutorial state (for settings or testing)
  Future<void> resetTutorial(String gameMode) async {
    await _prefs?.remove('$_prefix$gameMode');
  }

  /// Reset all tutorials
  Future<void> resetAllTutorials() async {
    final keys = _prefs?.getKeys().where((k) => k.startsWith(_prefix)) ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  /// Static helper to quickly check without async initialization
  /// Use only after getInstance has been called once (e.g., in main.dart)
  static bool hasSeenTutorialSync(String gameMode) {
    return _instance?.hasSeenTutorial(gameMode) ?? false;
  }
}

/// Game mode identifiers for tutorial tracking
class GameModes {
  static const String classicEcho = 'classic_echo';
  static const String luminaMatrix = 'lumina_matrix';
  static const String reflexMatch = 'reflex_match';
  static const String echoStream = 'echo_stream';
  static const String quantumFlux = 'quantum_flux';
  static const String practice = 'practice';
  static const String zen = 'zen';
}
