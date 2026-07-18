/// Haptic feedback service for Echo Memory
/// Provides tactile feedback for game interactions
library;

import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _enabled = true;

  bool get isEnabled => _enabled;

  /// Toggle haptics on/off
  void toggleHaptics(bool enabled) {
    _enabled = enabled;
  }

  /// Light tap feedback - for button taps, correct answers
  Future<void> lightImpact() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for combo triggers
  Future<void> mediumImpact() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for wrong answers, game over
  Future<void> heavyImpact() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - for UI selections
  Future<void> selectionClick() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Success pattern - quick double tap
  Future<void> success() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error pattern - strong single tap
  Future<void> error() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Combo pattern - escalating intensity
  Future<void> combo(int level) async {
    if (!_enabled) return;

    if (level >= 10) {
      // Legendary combo - triple heavy
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 80));
      }
    } else if (level >= 7) {
      // Fire combo - double heavy
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } else if (level >= 5) {
      // Amazing combo - heavy
      await HapticFeedback.heavyImpact();
    } else if (level >= 3) {
      // Good combo - medium
      await HapticFeedback.mediumImpact();
    }
  }

  /// Power-up activation - unique pattern
  Future<void> powerUp() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Achievement unlock - celebratory pattern
  Future<void> achievement() async {
    if (!_enabled) return;
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Game over - long heavy feedback
  Future<void> gameOver() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }
}
