/// Tutorial Overlay Widget for Echo Memory
/// A reusable step-based tutorial system with animated transitions
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import 'glass_container.dart';

/// Data model for a single tutorial step
class TutorialStep {
  final String title;
  final String description;
  final Widget demo;
  final IconData? icon;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.demo,
    this.icon,
  });
}

/// Full-screen tutorial overlay with step-based navigation
class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final String gameTitle;
  final Color accentColor;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.gameTitle,
    this.onSkip,
    this.accentColor = AppColors.orbBlue,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;
  bool _animating = false;

  void _nextStep() {
    if (_animating) return;

    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _animating = true;
        _currentStep++;
      });
      Future.delayed(300.ms, () {
        if (mounted) setState(() => _animating = false);
      });
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_animating || _currentStep == 0) return;

    setState(() {
      _animating = true;
      _currentStep--;
    });
    Future.delayed(300.ms, () {
      if (mounted) setState(() => _animating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final isLastStep = _currentStep == widget.steps.length - 1;

    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            _buildHeader(),

            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    // Step title with icon
                    _buildStepTitle(step),
                    const SizedBox(height: 24),

                    // Animated demo area (wrapped in RepaintBoundary for performance)
                    RepaintBoundary(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 300,
                          maxWidth: 350,
                        ),
                        child: AnimatedSwitcher(
                          duration: 300.ms,
                          child: KeyedSubtree(
                            key: ValueKey(_currentStep),
                            child: step.demo,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Text(
                          step.description,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate(key: ValueKey('desc_$_currentStep'))
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            _buildBottomNav(isLastStep),
          ],
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
          // Game title
          Text(
            widget.gameTitle,
            style: AppTextStyles.titleMedium.copyWith(
              color: widget.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Skip button
          if (widget.onSkip != null)
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(TutorialStep step) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (step.icon != null) ...[
              Icon(step.icon, color: widget.accentColor, size: 28),
              const SizedBox(width: 12),
            ],
            Text(
              step.title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        )
        .animate(key: ValueKey('title_$_currentStep'))
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildBottomNav(bool isLastStep) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.steps.length, (index) {
              final isActive = index == _currentStep;
              return AnimatedContainer(
                duration: 200.ms,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? widget.accentColor
                      : AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              // Back button (if not first step)
              if (_currentStep > 0)
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: 16,
                    onTap: _previousStep,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.arrowLeft,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text('Back', style: AppTextStyles.labelLarge),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 16),

              // Next/Start button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _nextStep,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor,
                          widget.accentColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Start Game' : 'Next',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastStep
                              ? LucideIcons.play
                              : LucideIcons.arrowRight,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
