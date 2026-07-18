/// Sound service for Echo Memory
/// Manages all game audio with enhanced feedback
/// CURRENTLY DISABLED per user request
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // AudioPlayers removed to prevent issues
  // final AudioPlayer _audioPlayer = AudioPlayer();
  // final AudioPlayer _bgMusicPlayer = AudioPlayer();

  bool _enabled = false; // Disabled by default
  double _volume = 0.0;

  bool get isEnabled => _enabled;
  double get volume => _volume;

  /// Toggle sound on/off
  void toggleSound(bool enabled) {
    _enabled = enabled;
    // No-op
  }

  /// Set volume (0.0 - 1.0)
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    // No-op
  }

  /// Play color sound based on orb index
  Future<void> playColorSound(int colorIndex) async {
    // No-op
  }

  /// Play correct answer sound
  Future<void> playCorrect() async {
    // No-op
  }

  /// Play wrong answer sound
  Future<void> playWrong() async {
    // No-op
  }

  /// Play victory/level complete sound
  Future<void> playVictory() async {
    // No-op
  }

  /// Play game over sound
  Future<void> playGameOver() async {
    // No-op
  }

  /// Play combo sound
  Future<void> playCombo(int comboLevel) async {
    // No-op
  }

  /// Play power-up activation
  Future<void> playPowerUp() async {
    // No-op
  }

  /// Play achievement unlock
  Future<void> playAchievement() async {
    // No-op
  }

  /// Play level up
  Future<void> playLevelUp() async {
    // No-op
  }

  /// Play button tap (subtle click)
  Future<void> playTap() async {
    // No-op
  }

  /// Clean up resources
  void dispose() {
    // No-op
  }
}
