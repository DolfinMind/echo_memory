/// Animated Demo Widgets for Echo Memory Tutorials
/// Pre-built, performance-optimized animated demonstrations
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/theme/app_colors.dart';

/// Animated orb demo for Classic Echo tutorial
class OrbSequenceDemo extends StatefulWidget {
  final List<Color> colors;
  final Duration stepDuration;
  final bool autoPlay;

  const OrbSequenceDemo({
    super.key,
    this.colors = const [Colors.blue, Colors.green, Colors.red],
    this.stepDuration = const Duration(milliseconds: 600),
    this.autoPlay = true,
  });

  @override
  State<OrbSequenceDemo> createState() => _OrbSequenceDemoState();
}

class _OrbSequenceDemoState extends State<OrbSequenceDemo> {
  int _activeOrb = -1;
  final List<int> _sequence = [0, 2, 1, 0]; // Demo sequence

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _playSequence();
    }
  }

  void _playSequence() async {
    await Future.delayed(500.ms);
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() => _activeOrb = _sequence[i]);
      await Future.delayed(widget.stepDuration);
      if (!mounted) return;
      setState(() => _activeOrb = -1);
      await Future.delayed(200.ms);
    }
    // Loop
    if (mounted) {
      await Future.delayed(1000.ms);
      _playSequence();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => _buildOrb(index)),
        ),
      ),
    );
  }

  Widget _buildOrb(int index) {
    final color = [
      AppColors.orbBlue,
      AppColors.orbGreen,
      AppColors.orbRed,
    ][index];
    final isActive = index == _activeOrb;

    return AnimatedContainer(
      duration: 200.ms,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: isActive ? 0.9 : 0.3),
        border: Border.all(color: color, width: isActive ? 3 : 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ]
            : [],
      ),
    );
  }
}

/// Grid pattern demo for Lumina Matrix tutorial
class GridPatternDemo extends StatefulWidget {
  final int gridSize;
  final Color activeColor;
  final bool showRecall;

  const GridPatternDemo({
    super.key,
    this.gridSize = 3,
    this.activeColor = AppColors.orbPurple,
    this.showRecall = false,
  });

  @override
  State<GridPatternDemo> createState() => _GridPatternDemoState();
}

class _GridPatternDemoState extends State<GridPatternDemo> {
  Set<int> _activePattern = {};
  Set<int> _userTaps = {};

  @override
  void initState() {
    super.initState();
    _startDemo();
  }

  void _startDemo() async {
    // Watch phase
    _activePattern = {0, 2, 4, 6}; // Demo pattern
    setState(() {});

    await Future.delayed(2000.ms);
    if (!mounted) return;

    // Hide pattern
    setState(() {
      _activePattern = {};
    });

    // Simulate recall taps
    await Future.delayed(500.ms);
    for (int tile in [0, 2, 4, 6]) {
      if (!mounted) return;
      setState(() => _userTaps.add(tile));
      await Future.delayed(400.ms);
    }

    // Success flash
    await Future.delayed(800.ms);
    if (!mounted) return;

    // Restart loop
    setState(() {
      _userTaps = {};
      _activePattern = {};
    });
    await Future.delayed(500.ms);
    if (mounted) _startDemo();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 180,
        height: 180,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSize,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: widget.gridSize * widget.gridSize,
          itemBuilder: (context, index) {
            final isPatternActive = _activePattern.contains(index);
            final isUserTapped = _userTaps.contains(index);
            final isActive = isPatternActive || isUserTapped;

            return AnimatedContainer(
              duration: 200.ms,
              decoration: BoxDecoration(
                color: isActive
                    ? widget.activeColor.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? widget.activeColor
                      : Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: widget.activeColor.withValues(alpha: 0.5),
                          blurRadius: 15,
                        ),
                      ]
                    : [],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Card comparison demo for Reflex Match tutorial
class CardComparisonDemo extends StatefulWidget {
  final bool showSameCards;

  const CardComparisonDemo({super.key, this.showSameCards = true});

  @override
  State<CardComparisonDemo> createState() => _CardComparisonDemoState();
}

class _CardComparisonDemoState extends State<CardComparisonDemo> {
  int _phase = 0; // 0: show first, 1: show second, 2: compare
  Color _card1Color = AppColors.orbBlue;
  IconData _card1Icon = LucideIcons.star;
  Color _card2Color = AppColors.orbBlue;
  IconData _card2Icon = LucideIcons.star;
  bool _showSame = true;

  @override
  void initState() {
    super.initState();
    _startDemo();
  }

  void _startDemo() async {
    _showSame = !_showSame; // Alternate between same/different

    // Set cards
    _card1Color = AppColors.orbBlue;
    _card1Icon = LucideIcons.star;
    _card2Color = _showSame ? AppColors.orbBlue : AppColors.orbGreen;
    _card2Icon = _showSame ? LucideIcons.star : LucideIcons.circle;

    // Phase 1: Show first card
    setState(() => _phase = 0);
    await Future.delayed(1000.ms);
    if (!mounted) return;

    // Phase 2: Show second card
    setState(() => _phase = 1);
    await Future.delayed(1000.ms);
    if (!mounted) return;

    // Phase 3: Compare
    setState(() => _phase = 2);
    await Future.delayed(1500.ms);
    if (!mounted) return;

    // Loop
    if (mounted) _startDemo();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card 1
            AnimatedOpacity(
              duration: 300.ms,
              opacity: _phase >= 0 ? 1.0 : 0.0,
              child: _buildCard(
                _card1Color,
                _card1Icon,
                _phase >= 1 ? 0.5 : 1.0,
              ),
            ),

            // Arrow/comparison
            if (_phase >= 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  _phase == 2
                      ? (_showSame ? LucideIcons.equal : LucideIcons.x)
                      : LucideIcons.arrowRight,
                  size: 28,
                  color: _phase == 2
                      ? (_showSame ? AppColors.orbGreen : AppColors.orbRed)
                      : Colors.white54,
                ),
              ).animate().fadeIn(duration: 200.ms),

            // Card 2
            if (_phase >= 1)
              AnimatedOpacity(
                duration: 300.ms,
                opacity: _phase >= 1 ? 1.0 : 0.0,
                child: _buildCard(_card2Color, _card2Icon, 1.0),
              ).animate().fadeIn().slideX(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Color color, IconData icon, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15),
          ],
        ),
        child: Icon(icon, color: color, size: 36),
      ),
    );
  }
}

/// Flowing items demo for Echo Stream tutorial
class FlowingItemsDemo extends StatefulWidget {
  const FlowingItemsDemo({super.key});

  @override
  State<FlowingItemsDemo> createState() => _FlowingItemsDemoState();
}

class _FlowingItemsDemoState extends State<FlowingItemsDemo> {
  final List<_FlowItem> _items = [
    _FlowItem(color: AppColors.orbRed, icon: LucideIcons.circle),
    _FlowItem(color: AppColors.orbBlue, icon: LucideIcons.square),
    _FlowItem(color: AppColors.orbGreen, icon: LucideIcons.triangle),
    _FlowItem(color: AppColors.orbYellow, icon: LucideIcons.star),
  ];

  int _hiddenIndex = -1;
  int _phase = 0; // 0: flowing, 1: hidden, 2: choices

  @override
  void initState() {
    super.initState();
    _startDemo();
  }

  void _startDemo() async {
    // Phase 0: Show all items flowing in
    setState(() {
      _phase = 0;
      _hiddenIndex = -1;
    });
    await Future.delayed(2000.ms);
    if (!mounted) return;

    // Phase 1: Hide one
    setState(() {
      _phase = 1;
      _hiddenIndex = 1; // Hide the blue square
    });
    await Future.delayed(1500.ms);
    if (!mounted) return;

    // Phase 2: Show choices (correct one highlights)
    setState(() => _phase = 2);
    await Future.delayed(2000.ms);
    if (!mounted) return;

    // Loop
    if (mounted) _startDemo();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stream items
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isHidden = _phase >= 1 && index == _hiddenIndex;

                return AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isHidden
                            ? Colors.white.withValues(alpha: 0.1)
                            : item.color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isHidden
                              ? Colors.white.withValues(alpha: 0.3)
                              : item.color,
                          width: 2,
                        ),
                      ),
                      child: isHidden
                          ? const Icon(
                              LucideIcons.helpCircle,
                              color: Colors.white38,
                              size: 24,
                            )
                          : Icon(item.icon, color: item.color, size: 24),
                    )
                    .animate(delay: (index * 100).ms)
                    .fadeIn()
                    .slideY(begin: 0.3, end: 0);
              }),
            ),

            // Choices
            if (_phase == 2) ...[
              const SizedBox(height: 24),
              const Text(
                'Which one was hidden?',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChoice(_items[0], false),
                  _buildChoice(_items[1], true), // Correct answer
                  _buildChoice(_items[3], false),
                ],
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoice(_FlowItem item, bool isCorrect) {
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.orbGreen.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect ? AppColors.orbGreen : Colors.white24,
          width: isCorrect ? 2 : 1,
        ),
      ),
      child: Icon(item.icon, color: item.color, size: 24),
    );
  }
}

class _FlowItem {
  final Color color;
  final IconData icon;

  _FlowItem({required this.color, required this.icon});
}

/// Tap indicator animation (finger icon with ripple)
class TapIndicator extends StatelessWidget {
  final Offset position;
  final Color color;

  const TapIndicator({
    super.key,
    required this.position,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.3),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3)),
          const SizedBox(height: 4),
          Icon(LucideIcons.mousePointer2, color: color, size: 20),
        ],
      ),
    );
  }
}
