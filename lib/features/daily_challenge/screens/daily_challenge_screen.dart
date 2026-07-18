/// Daily Challenge screen for Echo Memory
/// One deterministic, entirely offline challenge per day.
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/game/game_scoring.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../game/widgets/color_orb.dart';
import '../../home/screens/home_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final SoundService _soundService = SoundService();
  final HapticService _hapticService = HapticService();

  List<int> _sequence = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _showPattern = false;
  bool _hasPlayedToday = false;
  bool _isGameStarted = false;
  bool _isGameOver = false;
  int? _todayHighScore;
  int _highlightedOrbIndex = -1;
  Timer? _patternTimer;
  Timer? _flashTimer;
  Timer? _phaseTimer;
  late DateTime _today;
  late Random _random;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    // Seed random with today's date for consistent daily challenge
    _random = Random(_today.year * 10000 + _today.month * 100 + _today.day);
    _loadDailyChallenge();
  }

  @override
  void dispose() {
    _patternTimer?.cancel();
    _flashTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayedDate = prefs.getString('daily_challenge_date');
    final todayStr = _dateKey(_today);

    if (!mounted) return;
    if (lastPlayedDate == todayStr) {
      setState(() {
        _hasPlayedToday = true;
        _todayHighScore = prefs.getInt('daily_challenge_score');
      });
    }
  }

  Future<void> _saveDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _dateKey(_today);
    await prefs.setString('daily_challenge_date', todayStr);
    await prefs.setInt('daily_challenge_score', _score);
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _sequence = List.generate(4, (_) => _random.nextInt(5));
      _currentIndex = 0;
      _showPattern = true;
    });
    _displayPattern();
  }

  void _displayPattern() {
    _patternTimer?.cancel();
    _flashTimer?.cancel();
    _phaseTimer?.cancel();
    int displayIndex = 0;

    _patternTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (displayIndex < _sequence.length) {
        setState(() => _highlightedOrbIndex = _sequence[displayIndex]);
        _soundService.playColorSound(_sequence[displayIndex]);

        _flashTimer?.cancel();
        _flashTimer = Timer(const Duration(milliseconds: 350), () {
          if (mounted) setState(() => _highlightedOrbIndex = -1);
        });
        displayIndex++;
      } else {
        timer.cancel();
        _phaseTimer = Timer(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _showPattern = false);
        });
      }
    });
  }

  void _onOrbTap(int colorIndex) {
    if (_showPattern || _isGameOver || _currentIndex >= _sequence.length) {
      return;
    }

    _soundService.playColorSound(colorIndex);
    _hapticService.lightImpact();

    if (_sequence[_currentIndex] == colorIndex) {
      _soundService.playCorrect();
      setState(() {
        _score += GameScoring.correctColor(
          streak: _currentIndex + 1,
          difficultyMultiplier: 2,
        );
        _currentIndex++;
      });

      if (_currentIndex >= _sequence.length) {
        _handleLevelComplete();
      }
    } else {
      _handleGameOver();
    }
  }

  void _handleLevelComplete() {
    _soundService.playVictory();
    _hapticService.success();

    setState(() {
      _showPattern = true;
      _score += GameScoring.roundBonus(
        sequenceLength: _sequence.length,
        difficultyMultiplier: 2,
      );
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _sequence.add(_random.nextInt(5));
          _currentIndex = 0;
          _showPattern = true;
        });
        _displayPattern();
      }
    });
  }

  void _handleGameOver() {
    _soundService.playGameOver();
    _hapticService.gameOver();

    setState(() {
      _isGameOver = true;
      _hasPlayedToday = true;
      _todayHighScore = _score;
    });
    _saveDailyChallenge();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    return Scaffold(
      body: ParticleBackground(
        particleCount: 20,
        particleColor: AppColors.orbPurple.withValues(alpha: 0.3),
        child: GameGradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const Spacer(),
                  if (!_isGameStarted && !_hasPlayedToday)
                    _buildWelcome()
                  else if (_hasPlayedToday && !_isGameStarted)
                    _buildAlreadyPlayed()
                  else if (_isGameOver)
                    _buildGameOver()
                  else
                    _buildGameContent(),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.x,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.calendar,
              color: AppColors.orbPurple,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _dateLabel(_today),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.orbPurple,
              ),
            ),
          ],
        ),
        if (_isGameStarted)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.star,
                color: AppColors.accentGold,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '$_score',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else
          const SizedBox(width: 40),
      ],
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildWelcome() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orbPurple.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orbPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.calendarCheck,
              color: AppColors.orbPurple,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text('Daily Challenge', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'One attempt per day\nHow far can you go?',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          NeonButton(
            text: 'Start Challenge',
            color: AppColors.orbPurple,
            width: 180,
            icon: LucideIcons.play,
            onPressed: _startGame,
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildAlreadyPlayed() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.checkCircle,
            color: AppColors.orbGreen,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Already Played Today!',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.orbGreen,
            ),
          ),
          const SizedBox(height: 16),
          if (_todayHighScore != null) ...[
            Text('Your Score', style: AppTextStyles.labelMedium),
            Text(
              '$_todayHighScore',
              style: AppTextStyles.score.copyWith(fontSize: 48),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Come back tomorrow for\na new challenge!',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          NeonButton(
            text: 'Back Home',
            color: AppColors.orbBlue,
            width: 160,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildGameOver() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Challenge Complete!',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.accentGold,
            ),
          ),
          const SizedBox(height: 24),
          Text('Final Score', style: AppTextStyles.labelMedium),
          Text('$_score', style: AppTextStyles.score.copyWith(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Sequence Length: ${_sequence.length}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),
          NeonButton(
            text: 'Back Home',
            color: AppColors.orbBlue,
            width: 160,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildGameContent() {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          borderRadius: 16,
          child: Text(
            'Sequence: ${_sequence.length} colors',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.orbPurple,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _showPattern
              ? 'Watch carefully...'
              : 'Tap ${_currentIndex + 1} of ${_sequence.length}',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(5, (index) {
            return ColorOrb(
              colorIndex: index,
              size: ResponsiveUtils.getGameButtonSize().clamp(60, 90),
              onTap: () => _onOrbTap(index),
              isDisabled: _showPattern,
              isHighlighted: _highlightedOrbIndex == index,
            );
          }),
        ),
      ],
    );
  }
}
