import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/tutorial_overlay.dart';
import '../../../shared/widgets/animated_demo.dart';
import '../../../core/services/tutorial_service.dart';
import '../controllers/lumina_controller.dart';
import '../widgets/matrix_grid.dart';

class LuminaScreen extends StatefulWidget {
  const LuminaScreen({super.key});

  @override
  State<LuminaScreen> createState() => _LuminaScreenState();
}

class _LuminaScreenState extends State<LuminaScreen> {
  late LuminaGameController _controller;
  Timer? _phaseTimer;
  String _statusText = 'WATCH';
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _controller = LuminaGameController();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final tutorialService = await TutorialService.getInstance();
    if (!tutorialService.hasSeenTutorial(GameModes.luminaMatrix)) {
      if (mounted) {
        setState(() => _showTutorial = true);
      }
    } else {
      _startLevelSequence();
    }
  }

  void _completeTutorial() async {
    final tutorialService = await TutorialService.getInstance();
    await tutorialService.markTutorialComplete(GameModes.luminaMatrix);
    if (mounted) {
      setState(() => _showTutorial = false);
      _startLevelSequence();
    }
  }

  void _skipTutorial() async {
    final tutorialService = await TutorialService.getInstance();
    await tutorialService.markTutorialComplete(GameModes.luminaMatrix);
    if (mounted) {
      setState(() => _showTutorial = false);
      _startLevelSequence();
    }
  }

  List<TutorialStep> get _tutorialSteps => [
    const TutorialStep(
      title: 'Watch the Pattern',
      description:
          'Tiles will light up briefly. Focus and memorize their positions!',
      icon: LucideIcons.eye,
      demo: GridPatternDemo(gridSize: 3, activeColor: AppColors.orbPurple),
    ),
    TutorialStep(
      title: 'Remember Positions',
      description:
          'The pattern will disappear. Keep the tile positions in your memory.',
      icon: LucideIcons.brain,
      demo: _buildMemoryDemo(),
    ),
    TutorialStep(
      title: 'Tap to Recall',
      description:
          'Tap the tiles that were lit up. Get them all right to advance!',
      icon: LucideIcons.mousePointer2,
      demo: _buildTapDemo(),
    ),
  ];

  Widget _buildMemoryDemo() {
    return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(
            LucideIcons.brain,
            color: AppColors.orbPurple,
            size: 50,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.05, 1.05),
          duration: 1200.ms,
        );
  }

  Widget _buildTapDemo() {
    return SizedBox(
      width: 150,
      height: 150,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (index) {
          final isTarget = [0, 4, 8].contains(index);
          return Container(
                decoration: BoxDecoration(
                  color: isTarget
                      ? AppColors.orbPurple.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isTarget ? AppColors.orbPurple : Colors.white24,
                  ),
                ),
              )
              .animate(delay: (index * 80).ms)
              .fadeIn()
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
        }),
      ),
    );
  }

  void _startLevelSequence() {
    _controller.startGame(); // Generates pattern
    _statusText = 'WATCH PATTERN';

    // Show pattern for 2 seconds, then hide
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _statusText = 'RECALL NOW';
        _controller.startRecall();
      });
    });
  }

  void _handleGridTap(int index) {
    if (_controller.state != LuminaState.playing) return;

    _controller.handleTap(index);

    if (_controller.state == LuminaState.success) {
      _handleSuccess();
    } else if (_controller.state == LuminaState.failed) {
      _handleFailure();
    }
  }

  void _handleSuccess() {
    setState(() => _statusText = 'EXCELLENT!');
    // Wait then next round
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _controller.nextRound(); // Generates new level
      setState(() => _statusText = 'WATCH PATTERN');

      // Pattern display logic again
      _phaseTimer?.cancel();
      _phaseTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _statusText = 'RECALL NOW';
          _controller.startRecall();
        });
      });
    });
  }

  void _handleFailure() {
    setState(() => _statusText = 'GAME OVER');
    // Simple retry dialog for now
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Game Over', style: AppTextStyles.headlineMedium),
        content: Text(
          'Score: ${_controller.score}\nLevel: ${_controller.level}',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startLevelSequence(); // Restart
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orbBlue),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Main game content
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGrid(),
                              const SizedBox(height: 32),
                              _buildStatus(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Tutorial overlay
              if (_showTutorial)
                TutorialOverlay(
                  gameTitle: 'LUMINA MATRIX',
                  accentColor: AppColors.orbPurple,
                  steps: _tutorialSteps,
                  onComplete: _completeTutorial,
                  onSkip: _skipTutorial,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              LucideIcons.arrowLeft,
              color: Colors.white70,
              size: 24,
            ),
          ),
          Row(
            children: [
              Text(
                'LV ${_controller.level}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.orbPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(LucideIcons.gem, color: AppColors.orbBlue, size: 16),
              const SizedBox(width: 4),
              Text('${_controller.score}', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return MatrixGrid(
      gridSize: _controller.gridSize,
      activeIndices: _controller.state == LuminaState.watching
          ? _controller.activePattern
          : _controller.state == LuminaState.playing ||
                _controller.state == LuminaState.success
          ? _controller
                .activePattern // Show what user tapped
          : _controller.activePattern, // Show correct pattern on fail?
      onTap: _handleGridTap,
      state: _controller.state,
    );
  }

  Widget _buildStatus() {
    Color color = AppColors.textPrimary;
    if (_controller.state == LuminaState.watching) color = AppColors.orbBlue;
    if (_controller.state == LuminaState.playing) color = AppColors.orbGreen;
    if (_controller.state == LuminaState.failed) color = AppColors.orbRed;

    return Text(
      _statusText,
      style: AppTextStyles.headlineMedium.copyWith(
        color: color,
        letterSpacing: 3,
      ),
    ).animate(key: ValueKey(_statusText)).fadeIn().slideY(begin: 0.2, end: 0);
  }
}
