/// Power-up bar widget for Echo Memory
/// Displays available power-ups with activation UI
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../data/models/power_up.dart';

class PowerUpBar extends StatelessWidget {
  final PowerUpInventory inventory;
  final PowerUpType? activePowerUp;
  final Function(PowerUpType)? onPowerUpTap;
  final bool isDisabled;

  const PowerUpBar({
    super.key,
    required this.inventory,
    this.activePowerUp,
    this.onPowerUpTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: PowerUp.allPowerUps.map((powerUp) {
          final quantity = inventory.getQuantity(powerUp.type);
          final isActive = activePowerUp == powerUp.type;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _PowerUpButton(
              powerUp: powerUp,
              quantity: quantity,
              isActive: isActive,
              isDisabled: isDisabled || quantity == 0,
              onTap: () => onPowerUpTap?.call(powerUp.type),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PowerUpButton extends StatefulWidget {
  final PowerUp powerUp;
  final int quantity;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _PowerUpButton({
    required this.powerUp,
    required this.quantity,
    required this.isActive,
    required this.isDisabled,
    this.onTap,
  });

  @override
  State<_PowerUpButton> createState() => _PowerUpButtonState();
}

class _PowerUpButtonState extends State<_PowerUpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PowerUpButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canUse = !widget.isDisabled && widget.quantity > 0;

    return GestureDetector(
      onTap: canUse ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glowIntensity = widget.isActive ? _controller.value : 0.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Button container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canUse
                      ? widget.powerUp.color.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  border: Border.all(
                    color: canUse
                        ? widget.powerUp.color.withValues(alpha: 0.6)
                        : Colors.grey.withValues(alpha: 0.3),
                    width: widget.isActive ? 2 : 1,
                  ),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: widget.powerUp.color.withValues(
                              alpha: 0.3 + glowIntensity * 0.3,
                            ),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.powerUp.icon,
                  color: canUse
                      ? widget.powerUp.color
                      : Colors.grey.withValues(alpha: 0.5),
                  size: 24,
                ),
              ),

              // Quantity badge
              if (widget.quantity > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.powerUp.color,
                      boxShadow: [
                        BoxShadow(
                          color: widget.powerUp.color.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${widget.quantity}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-screen power-up activation overlay
class PowerUpActivationOverlay extends StatelessWidget {
  final PowerUp powerUp;
  final VoidCallback? onComplete;

  const PowerUpActivationOverlay({
    super.key,
    required this.powerUp,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow
            Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: powerUp.color.withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: powerUp.color.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(powerUp.icon, color: powerUp.color, size: 50),
                )
                .animate(onComplete: (_) => onComplete?.call())
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.2, 1.2),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 200.ms,
                ),
            const SizedBox(height: 20),
            // Power-up name
            Text(
                  powerUp.name.toUpperCase(),
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: powerUp.color,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            // Description
            Text(
              powerUp.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).then(delay: 1200.ms).fadeOut();
  }
}

/// Mini power-up display for showing active effects
class ActivePowerUpIndicator extends StatelessWidget {
  final PowerUp powerUp;
  final int remainingSeconds;

  const ActivePowerUpIndicator({
    super.key,
    required this.powerUp,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: powerUp.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: powerUp.color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(powerUp.icon, color: powerUp.color, size: 16),
              const SizedBox(width: 6),
              Text(
                '${remainingSeconds}s',
                style: AppTextStyles.labelMedium.copyWith(
                  color: powerUp.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 1000.ms,
          color: powerUp.color.withValues(alpha: 0.3),
        );
  }
}
