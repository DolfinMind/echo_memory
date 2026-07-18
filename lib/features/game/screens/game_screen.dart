import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/game/game_scoring.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/tutorial_service.dart';
import '../../../data/models/player_stats.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../widgets/color_orb.dart';
import '../widgets/score_display.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  final Map<String, int> settings;

  const GameScreen({
    super.key,
    required this.difficulty,
    required this.settings,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SoundService _soundService = SoundService();
  final HapticService _hapticService = HapticService();
  final StorageService _storageService = StorageService();
  final Random _random = Random();

  List<int> _sequence = [];
  List<int> _orbMapping = [0, 1, 2, 3, 4];
  int _currentIndex = 0;
  int _score = 0;
  int _lives = 3;
  int _level = 1;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _timeRemaining = 0;
  int _highlightedOrbIndex = -1;
  int _correctAnswers = 0;
  int _mistakes = 0;
  int? _lastAward;
  String? _feedback;
  bool _showPattern = true;
  bool _isTransitioning = false;
  bool _isGameOver = false;
  bool _roundIsPerfect = true;
  bool _showTutorial = false;
  bool _resultSaved = false;
  late DateTime _startedAt;

  Timer? _gameTimer;
  Timer? _patternTimer;
  Timer? _flashTimer;
  Timer? _phaseTimer;

  bool get _isQuantumMode => widget.difficulty == 'quantum';
  bool get _isZenMode => widget.difficulty == 'zen';
  int get _initialSequence => widget.settings['initialSequence'] ?? 3;
  int get _difficultyMultiplier => widget.settings['pointMultiplier'] ?? 1;
  int get _timeLimit => widget.settings['timeLimit'] ?? 10;

  Color get _accentColor {
    if (_isQuantumMode) return AppColors.orbPurple;
    if (_isZenMode) return AppColors.orbGreen;
    return switch (widget.difficulty) {
      'master' => AppColors.difficultyMaster,
      'expert' => AppColors.difficultyExpert,
      _ => AppColors.orbBlue,
    };
  }

  String get _modeTitle {
    if (_isQuantumMode) return 'Quantum Flux';
    if (_isZenMode) return 'Zen Echo';
    return '${widget.difficulty[0].toUpperCase()}${widget.difficulty.substring(1)} Echo';
  }

  @override
  void initState() {
    super.initState();
    _lives = widget.settings['lives'] ?? 3;
    _startedAt = DateTime.now();
    _checkTutorial();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _gameTimer?.cancel();
    _patternTimer?.cancel();
    _flashTimer?.cancel();
    _phaseTimer?.cancel();
  }

  Future<void> _checkTutorial() async {
    final mode = _isQuantumMode
        ? GameModes.quantumFlux
        : _isZenMode
        ? GameModes.zen
        : GameModes.classicEcho;
    final tutorialService = await TutorialService.getInstance();
    if (!mounted) return;
    if (tutorialService.hasSeenTutorial(mode)) {
      _startNewGame();
    } else {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _completeTutorial() async {
    final mode = _isQuantumMode
        ? GameModes.quantumFlux
        : _isZenMode
        ? GameModes.zen
        : GameModes.classicEcho;
    final tutorialService = await TutorialService.getInstance();
    await tutorialService.markTutorialComplete(mode);
    if (!mounted) return;
    setState(() => _showTutorial = false);
    _startNewGame();
  }

  void _startNewGame() {
    _cancelTimers();
    _startedAt = DateTime.now();
    setState(() {
      _sequence = List.generate(_initialSequence, (_) => _random.nextInt(5));
      _orbMapping = [0, 1, 2, 3, 4];
      _currentIndex = 0;
      _score = 0;
      _lives = widget.settings['lives'] ?? 3;
      _level = 1;
      _currentStreak = 0;
      _bestStreak = 0;
      _timeRemaining = _timeLimit;
      _correctAnswers = 0;
      _mistakes = 0;
      _lastAward = null;
      _feedback = null;
      _showPattern = true;
      _isTransitioning = false;
      _isGameOver = false;
      _roundIsPerfect = true;
      _resultSaved = false;
    });
    _presentPattern();
  }

  Duration get _patternInterval {
    if (_isZenMode) return const Duration(milliseconds: 820);
    return switch (widget.difficulty) {
      'master' => const Duration(milliseconds: 520),
      'expert' => const Duration(milliseconds: 640),
      _ => const Duration(milliseconds: 740),
    };
  }

  void _presentPattern() {
    _gameTimer?.cancel();
    _patternTimer?.cancel();
    _flashTimer?.cancel();
    _phaseTimer?.cancel();
    var displayIndex = 0;

    setState(() {
      _showPattern = true;
      _isTransitioning = false;
      _currentIndex = 0;
      _highlightedOrbIndex = -1;
      _feedback = null;
      _lastAward = null;
    });

    void showNext() {
      if (!mounted) return;
      if (displayIndex >= _sequence.length) {
        _patternTimer?.cancel();
        _phaseTimer = Timer(const Duration(milliseconds: 320), _beginRecall);
        return;
      }

      final colorIndex = _sequence[displayIndex++];
      setState(() => _highlightedOrbIndex = colorIndex);
      _soundService.playColorSound(colorIndex);
      _flashTimer?.cancel();
      _flashTimer = Timer(
        Duration(milliseconds: min(360, _patternInterval.inMilliseconds - 120)),
        () {
          if (mounted) setState(() => _highlightedOrbIndex = -1);
        },
      );
    }

    showNext();
    _patternTimer = Timer.periodic(_patternInterval, (_) => showNext());
  }

  void _beginRecall() {
    if (!mounted || _isGameOver) return;
    if (_isQuantumMode) _orbMapping.shuffle(_random);
    setState(() {
      _highlightedOrbIndex = -1;
      _showPattern = false;
      _isTransitioning = false;
      _timeRemaining = _timeLimit;
    });
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    if (_timeLimit == 0) return;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isGameOver || _showPattern) {
        timer.cancel();
        return;
      }
      if (_timeRemaining <= 1) {
        timer.cancel();
        setState(() => _timeRemaining = 0);
        _handleMiss('Time expired');
      } else {
        setState(() => _timeRemaining--);
      }
    });
  }

  void _onOrbTap(int colorIndex) {
    if (_showPattern || _isTransitioning || _isGameOver) return;
    if (_currentIndex >= _sequence.length) return;

    _soundService.playColorSound(colorIndex);
    _hapticService.selectionClick();

    if (_sequence[_currentIndex] == colorIndex) {
      _handleCorrectAnswer();
    } else {
      _handleMiss('That was ${_orbName(colorIndex)}');
    }
  }

  void _handleCorrectAnswer() {
    final nextStreak = _currentStreak + 1;
    final points = GameScoring.correctColor(
      streak: nextStreak,
      difficultyMultiplier: _difficultyMultiplier,
    );
    final completesRound = _currentIndex + 1 >= _sequence.length;

    setState(() {
      _currentStreak = nextStreak;
      _bestStreak = max(_bestStreak, nextStreak);
      _correctAnswers++;
      _score += points;
      _currentIndex++;
      _lastAward = points;
      _feedback = 'Correct';
      if (completesRound) {
        _showPattern = true;
        _isTransitioning = true;
      }
    });

    if (_currentStreak >= 3) {
      _hapticService.combo(_currentStreak);
    } else {
      _hapticService.lightImpact();
    }
    _soundService.playCorrect();

    if (completesRound) {
      _gameTimer?.cancel();
      _completeRound();
    }
  }

  void _handleMiss(String message) {
    if (_isTransitioning || _isGameOver) return;
    _gameTimer?.cancel();
    _soundService.playWrong();
    _hapticService.error();

    final losesLife = !_isZenMode;
    setState(() {
      if (losesLife) _lives--;
      _mistakes++;
      _currentStreak = 0;
      _currentIndex = 0;
      _roundIsPerfect = false;
      _feedback = message;
      _lastAward = null;
      _isTransitioning = true;
    });

    if (losesLife && _lives <= 0) {
      _finishGame();
      return;
    }

    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted && !_isGameOver) _presentPattern();
    });
  }

  void _completeRound() {
    final bonus = GameScoring.roundBonus(
      sequenceLength: _sequence.length,
      difficultyMultiplier: _difficultyMultiplier,
      timeRemaining: _timeRemaining,
      perfect: _roundIsPerfect,
    );
    _soundService.playVictory();
    _hapticService.success();

    setState(() {
      _score += bonus;
      _lastAward = bonus;
      _feedback = _roundIsPerfect ? 'Perfect recall' : 'Round clear';
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted || _isGameOver) return;
      setState(() {
        _sequence.add(_random.nextInt(5));
        _level++;
        _roundIsPerfect = true;
        _isTransitioning = false;
      });
      _presentPattern();
    });
  }

  void _finishGame() {
    _cancelTimers();
    _soundService.playGameOver();
    _hapticService.gameOver();
    setState(() {
      _isGameOver = true;
      _isTransitioning = true;
      _showPattern = false;
      _feedback = null;
    });
    _saveResult();
  }

  Future<void> _saveResult() async {
    if (_resultSaved) return;
    _resultSaved = true;
    final playTime = DateTime.now().difference(_startedAt);
    final PlayerStats current = await _storageService.getPlayerStats();
    final updated = current.recordGame(
      score: _score,
      streak: _bestStreak,
      sequenceLength: _sequence.length,
      correctAnswers: _correctAnswers,
      mistakes: _mistakes,
      playTime: playTime,
      gameMode: _isQuantumMode
          ? 'quantum'
          : _isZenMode
          ? 'zen'
          : 'classic',
      difficulty: widget.difficulty,
    );
    await _storageService.setPlayerStats(updated);
    await _storageService.setHighScore(updated.highScore);
    await _storageService.setBestStreak(updated.bestStreak);
  }

  String _orbName(int index) =>
      const ['Coral', 'Mint', 'Blue', 'Gold', 'Violet'][index % 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameGradientBackground(
        showOverlay: false,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _isGameOver
                        ? _buildGameOver()
                        : _buildResponsiveGame(),
                  ),
                ],
              ),
              if (_showTutorial) _buildTutorial(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 48,
            child: IconButton.filledTonal(
              tooltip: 'Leave game',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.x, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_modeTitle, style: AppTextStyles.titleSmall),
                Text(
                  'Level $_level  •  ${_sequence.length} signals',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          _MetricChip(
            icon: LucideIcons.star,
            label: 'Score',
            value: '$_score',
            color: AppColors.accentGold,
          ),
          const SizedBox(width: 8),
          if (_timeLimit > 0 && !_showPattern)
            CircularTimer(
              timeRemaining: _timeRemaining,
              totalTime: _timeLimit,
              size: 44,
            )
          else
            LivesDisplay(
              lives: _lives,
              maxLives: widget.settings['lives'] ?? 3,
              size: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGame() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720 || constraints.maxHeight < 500;
        final status = _buildStatusPanel();
        final board = _buildOrbBoard(wide: wide);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 32 : 20,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: wide
                ? Row(
                    children: [
                      Expanded(child: status),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: board),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [status, const SizedBox(height: 28), board],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStatusPanel() {
    final progress = _sequence.isEmpty ? 0.0 : _currentIndex / _sequence.length;
    final heading = _showPattern
        ? 'Watch the signal'
        : _isTransitioning
        ? (_feedback ?? 'Hold that thought')
        : 'Repeat the pattern';
    final supporting = _showPattern
        ? 'Each icon flashes once. Remember the order.'
        : _isTransitioning
        ? (_lastAward == null
              ? 'The sequence will replay.'
              : '+$_lastAward points')
        : 'Tap ${_currentIndex + 1} of ${_sequence.length}';

    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _accentColor.withValues(alpha: 0.38)),
            ),
            child: Text(
              _showPattern ? 'WATCH' : 'YOUR TURN',
              style: AppTextStyles.labelMedium.copyWith(
                color: _accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            heading,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            supporting,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: _showPattern ? null : progress.clamp(0, 1),
                backgroundColor: AppColors.surfaceLight,
                color: _accentColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.flame, size: 17, color: AppColors.orbRed),
              const SizedBox(width: 6),
              Text('$_currentStreak streak', style: AppTextStyles.labelMedium),
              if (_currentStreak >= 3) ...[
                const SizedBox(width: 8),
                Text(
                  '×${GameScoring.comboMultiplier(_currentStreak)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrbBoard({required bool wide}) {
    final orbSize = wide ? 78.0 : 72.0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          backgroundColor: AppColors.surface.withValues(alpha: 0.72),
          borderColor: _accentColor.withValues(alpha: 0.22),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: List.generate(5, (physicalIndex) {
              final colorIndex = _orbMapping[physicalIndex];
              return ColorOrb(
                key: ValueKey('orb-$physicalIndex-$colorIndex'),
                colorIndex: colorIndex,
                size: orbSize,
                onTap: () => _onOrbTap(colorIndex),
                isDisabled: _showPattern || _isTransitioning,
                isHighlighted: _highlightedOrbIndex == colorIndex,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          width: 440,
          padding: const EdgeInsets.all(28),
          backgroundColor: AppColors.surface.withValues(alpha: 0.92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accentError.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.flag,
                  color: AppColors.accentError,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text('Session complete', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '$_score',
                style: AppTextStyles.score.copyWith(fontSize: 56),
              ),
              Text('points', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ResultStat(label: 'Level', value: '$_level'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResultStat(
                      label: 'Best streak',
                      value: '$_bestStreak',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResultStat(
                      label: 'Sequence',
                      value: '${_sequence.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              NeonButton(
                text: 'Play again',
                width: double.infinity,
                color: _accentColor,
                icon: LucideIcons.refreshCw,
                onPressed: _startNewGame,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to modes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorial() {
    final description = _isQuantumMode
        ? 'Watch the colors and icons, then repeat them after the buttons shuffle. Positions are a distraction.'
        : _isZenMode
        ? 'Watch each signal, then tap the same icons in order. There is no timer and mistakes do not end the session.'
        : 'Watch each signal, then tap the same color-and-icon buttons in order. Longer streaks earn a score multiplier.';

    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xCC070B16),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassContainer(
              width: 420,
              padding: const EdgeInsets.all(28),
              backgroundColor: AppColors.surface,
              borderColor: _accentColor.withValues(alpha: 0.45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.brain, color: _accentColor, size: 42),
                  const SizedBox(height: 18),
                  Text(_modeTitle, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  NeonButton(
                    text: 'Start training',
                    width: double.infinity,
                    color: _accentColor,
                    icon: LucideIcons.play,
                    onPressed: _completeTutorial,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;

  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleLarge),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
