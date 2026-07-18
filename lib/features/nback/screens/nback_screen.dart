import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/tutorial_overlay.dart';
import '../../../shared/widgets/animated_demo.dart';
import '../../../core/services/tutorial_service.dart';
import '../controllers/nback_controller.dart';

class NBackScreen extends StatefulWidget {
  const NBackScreen({super.key});

  @override
  State<NBackScreen> createState() => _NBackScreenState();
}

class _NBackScreenState extends State<NBackScreen> {
  late ReflexController _controller;
  bool _showTutorial = false;

  static const List<Color> cardColors = [
    AppColors.orbRed,
    AppColors.orbBlue,
    AppColors.orbGreen,
    AppColors.orbYellow,
    AppColors.orbPurple,
    Color(0xFFFF9F43),
  ];

  static const List<IconData> cardShapes = [
    LucideIcons.circle,
    LucideIcons.square,
    LucideIcons.triangle,
    LucideIcons.star,
    LucideIcons.heart,
  ];

  @override
  void initState() {
    super.initState();
    _controller = ReflexController();
    _controller.startGame();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final tutorialService = await TutorialService.getInstance();
    if (!tutorialService.hasSeenTutorial(GameModes.reflexMatch)) {
      if (mounted) {
        setState(() => _showTutorial = true);
      }
    }
  }

  void _completeTutorial() async {
    final tutorialService = await TutorialService.getInstance();
    await tutorialService.markTutorialComplete(GameModes.reflexMatch);
    if (mounted) {
      setState(() => _showTutorial = false);
      _controller.showNextCard();
    }
  }

  void _skipTutorial() async {
    final tutorialService = await TutorialService.getInstance();
    await tutorialService.markTutorialComplete(GameModes.reflexMatch);
    if (mounted) {
      setState(() => _showTutorial = false);
      _controller.showNextCard();
    }
  }

  List<TutorialStep> get _tutorialSteps => [
    TutorialStep(
      title: 'Watch the Card',
      description:
          'A card with a color and shape appears. Take a moment to memorize it.',
      icon: LucideIcons.eye,
      demo: _buildTutorialCard(AppColors.orbBlue, LucideIcons.star),
    ),
    const TutorialStep(
      title: 'Compare Cards',
      description:
          'When the next card appears, compare it to the previous one.',
      icon: LucideIcons.gitCompare,
      demo: CardComparisonDemo(),
    ),
    TutorialStep(
      title: 'Make Your Choice',
      description:
          'Tap SAME if the cards match exactly, or DIFFERENT if not. Build your streak!',
      icon: LucideIcons.zap,
      demo: _buildButtonsDemo(),
    ),
  ];

  Widget _buildTutorialCard(Color color, IconData icon) {
    return Container(
          width: 100,
          height: 130,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 50),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 1500.ms,
        );
  }

  Widget _buildButtonsDemo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDemoButton('SAME', AppColors.orbGreen, LucideIcons.equal, true),
        const SizedBox(width: 20),
        _buildDemoButton('DIFF', AppColors.orbRed, LucideIcons.x, false),
      ],
    );
  }

  Widget _buildDemoButton(
    String label,
    Color color,
    IconData icon,
    bool pulse,
  ) {
    Widget button = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: color)),
        ],
      ),
    );

    if (pulse) {
      return button
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 800.ms,
          );
    }
    return button;
  }

  @override
  void dispose() {
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
                builder: (context, _) {
                  return Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildContent()),
                    ],
                  );
                },
              ),
              // Tutorial overlay
              if (_showTutorial)
                TutorialOverlay(
                  gameTitle: 'REFLEX MATCH',
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
              const Icon(
                LucideIcons.flame,
                color: AppColors.orbYellow,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${_controller.streak}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.orbYellow,
                ),
              ),
              const SizedBox(width: 16),
              Text('${_controller.score}', style: AppTextStyles.titleMedium),
            ],
          ),
          Row(
            children: List.generate(
              3,
              (i) => Icon(
                LucideIcons.heart,
                color: i < _controller.lives
                    ? AppColors.orbRed
                    : AppColors.textMuted.withValues(alpha: 0.3),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_controller.state) {
      case ReflexState.ready:
        return _buildStartScreen();
      case ReflexState.waiting:
        return _buildGamePlay();
      case ReflexState.feedback:
        return _buildFeedback();
      case ReflexState.gameOver:
        return _buildGameOver();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStartScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(LucideIcons.zap, size: 60, color: AppColors.orbPurple),
          const SizedBox(height: 16),
          Text('REFLEX MATCH', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 32),

          // Demo section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Text(
                  'HOW TO PLAY',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.orbBlue,
                  ),
                ),
                const SizedBox(height: 16),

                // Step 1
                _buildDemoStep(
                  step: '1',
                  text: 'A card appears',
                  child: _buildMiniCard(AppColors.orbBlue, LucideIcons.star),
                ),
                const SizedBox(height: 12),

                // Step 2
                _buildDemoStep(
                  step: '2',
                  text: 'Next card shows',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniCard(
                        AppColors.orbBlue,
                        LucideIcons.star,
                        opacity: 0.4,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          LucideIcons.arrowRight,
                          size: 20,
                          color: Colors.white54,
                        ),
                      ),
                      _buildMiniCard(AppColors.orbGreen, LucideIcons.circle),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Step 3
                _buildDemoStep(
                  step: '3',
                  text: 'Tap SAME if identical, DIFFERENT if not',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orbGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'SAME',
                          style: TextStyle(
                            color: AppColors.orbGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orbRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DIFF',
                          style: TextStyle(
                            color: AppColors.orbRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _controller.showNextCard(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orbPurple,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.play, size: 20),
                const SizedBox(width: 8),
                Text(
                  'START GAME',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildDemoStep({
    required String step,
    required String text,
    required Widget child,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.orbPurple.withValues(alpha: 0.3),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(Color color, IconData icon, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildGamePlay() {
    final card = _controller.currentCard;
    if (card == null) return const SizedBox();

    // Show inline feedback for correct answers
    final showCorrectFlash =
        _controller.lastAnswerCorrect == true &&
        _controller.state == ReflexState.waiting;

    return Column(
      children: [
        const Spacer(),
        // Instruction or feedback
        if (showCorrectFlash)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.check,
                color: AppColors.orbGreen,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '+${_controller.lastAward}',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.orbGreen,
                ),
              ),
            ],
          ).animate().fadeIn().scale()
        else
          Text(
            _controller.isFirstCard
                ? 'MEMORIZE THIS CARD'
                : 'SAME or DIFFERENT?',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.orbBlue,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(),
        const SizedBox(height: 40),
        // Card display with optional green glow on correct
        _buildCard(card, showCorrectGlow: showCorrectFlash),
        const Spacer(),
        // Buttons (hide on first card)
        if (!_controller.isFirstCard) _buildButtons(),
        // First card: tap to continue
        if (_controller.isFirstCard)
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () => _controller.showNextCard(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orbBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('NEXT CARD'),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCard(ReflexCard card, {bool showCorrectGlow = false}) {
    final color = showCorrectGlow
        ? AppColors.orbGreen
        : cardColors[card.colorIndex];
    final shape = cardShapes[card.shapeIndex];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: showCorrectGlow ? 4 : 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: showCorrectGlow ? 0.6 : 0.4),
            blurRadius: showCorrectGlow ? 40 : 30,
            spreadRadius: showCorrectGlow ? 8 : 5,
          ),
        ],
      ),
      child: Icon(
        shape,
        size: 80,
        color: showCorrectGlow
            ? AppColors.orbGreen
            : cardColors[card.colorIndex],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildAnswerButton(
              label: 'SAME',
              color: AppColors.orbGreen,
              icon: LucideIcons.equal,
              onTap: _controller.answerSame,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAnswerButton(
              label: 'DIFFERENT',
              color: AppColors.orbRed,
              icon: LucideIcons.x,
              onTap: _controller.answerDifferent,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAnswerButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final correct = _controller.lastAnswerCorrect ?? false;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            correct ? LucideIcons.checkCircle : LucideIcons.xCircle,
            size: 100,
            color: correct ? AppColors.orbGreen : AppColors.orbRed,
          ),
          const SizedBox(height: 16),
          Text(
            correct ? 'CORRECT!' : 'WRONG!',
            style: AppTextStyles.headlineLarge.copyWith(
              color: correct ? AppColors.orbGreen : AppColors.orbRed,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _controller.continueGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orbPurple,
            ),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildGameOver() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.zap, size: 64, color: AppColors.orbPurple),
            const SizedBox(height: 16),
            Text('Game Over!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Score: ${_controller.score}',
              style: AppTextStyles.titleLarge,
            ),
            Text(
              'Best Streak: ${_controller.streak}',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Exit'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _controller.startGame();
                    _controller.showNextCard();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orbPurple,
                  ),
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }
}
