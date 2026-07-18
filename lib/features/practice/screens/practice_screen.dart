/// Practice screen for Echo Memory
/// Relaxed mode without time limits
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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

class PracticeGameScreen extends StatefulWidget {
  const PracticeGameScreen({super.key});

  @override
  State<PracticeGameScreen> createState() => _PracticeGameScreenState();
}

class _PracticeGameScreenState extends State<PracticeGameScreen> {
  final SoundService _soundService = SoundService();
  final HapticService _hapticService = HapticService();
  final Random _random = Random();

  List<int> _sequence = [];
  int _currentIndex = 0;
  int _score = 0;
  int _level = 1;
  int _mistakes = 0;
  bool _showPattern = true;
  bool _canReveal = true;
  int _highlightedOrbIndex = -1;
  Timer? _patternTimer;
  Timer? _flashTimer;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _generateSequence();
  }

  @override
  void dispose() {
    _patternTimer?.cancel();
    _flashTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _generateSequence() {
    setState(() {
      _sequence = List.generate(3, (_) => _random.nextInt(5));
      _currentIndex = 0;
      _showPattern = true;
      _canReveal = true;
    });
    _displayPattern();
  }

  void _displayPattern() {
    _patternTimer?.cancel();
    _flashTimer?.cancel();
    _phaseTimer?.cancel();
    int displayIndex = 0;

    _patternTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (displayIndex < _sequence.length) {
        setState(() => _highlightedOrbIndex = _sequence[displayIndex]);
        _soundService.playColorSound(_sequence[displayIndex]);

        _flashTimer?.cancel();
        _flashTimer = Timer(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _highlightedOrbIndex = -1);
        });
        displayIndex++;
      } else {
        timer.cancel();
        _phaseTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _showPattern = false);
        });
      }
    });
  }

  void _onOrbTap(int colorIndex) {
    if (_showPattern || _currentIndex >= _sequence.length) return;

    _soundService.playColorSound(colorIndex);
    _hapticService.lightImpact();

    if (_sequence[_currentIndex] == colorIndex) {
      // Correct
      _soundService.playCorrect();
      setState(() {
        _score += GameScoring.correctColor(streak: _currentIndex + 1);
        _currentIndex++;
      });

      if (_currentIndex >= _sequence.length) {
        _handleLevelComplete();
      }
    } else {
      // Wrong
      _soundService.playWrong();
      _hapticService.error();
      setState(() {
        _mistakes++;
        _currentIndex = 0;
      });
    }
  }

  void _handleLevelComplete() {
    _soundService.playVictory();
    _hapticService.success();

    setState(() {
      _showPattern = true;
      _score += GameScoring.roundBonus(
        sequenceLength: _sequence.length,
        difficultyMultiplier: 1,
      );
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _sequence.add(_random.nextInt(5));
          _currentIndex = 0;
          _level++;
          _showPattern = true;
          _canReveal = true;
        });
        _displayPattern();
      }
    });
  }

  void _revealPattern() {
    if (!_canReveal || _showPattern) return;

    setState(() {
      _canReveal = false;
      _showPattern = true;
      _currentIndex = 0;
    });
    _displayPattern();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    return Scaffold(
      body: GameGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildGameContent(),
                const Spacer(),
                _buildRevealButton(),
                const SizedBox(height: 24),
              ],
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
        // Left: Back + Mode label
        Row(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.graduationCap,
                  color: AppColors.orbGreen,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Practice',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.orbGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Center: Score
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.star, color: AppColors.accentGold, size: 16),
            const SizedBox(width: 6),
            Text(
              '$_score',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Right: Stats
        _buildStats(),
      ],
    );
  }

  Widget _buildStats() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 12,
      child: Row(
        children: [
          _buildStatChip('Level', '$_level', AppColors.orbBlue),
          const SizedBox(width: 16),
          _buildStatChip('Mistakes', '$_mistakes', AppColors.accentError),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
      ],
    );
  }

  Widget _buildGameContent() {
    return Column(
      children: [
        Text(
          _showPattern
              ? 'Watch carefully...'
              : 'Tap color ${_currentIndex + 1} of ${_sequence.length}',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 32),
        // Color orbs
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

  Widget _buildRevealButton() {
    return NeonButton(
      text: _canReveal ? 'Reveal Pattern' : 'Pattern Revealed',
      icon: LucideIcons.eye,
      color: _canReveal ? AppColors.orbPurple : AppColors.textMuted,
      width: 200,
      isDisabled: !_canReveal || _showPattern,
      onPressed: _revealPattern,
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0);
  }
}
