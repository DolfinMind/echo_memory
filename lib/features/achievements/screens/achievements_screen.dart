/// Achievements screen for Echo Memory
/// Display all achievements and progress
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../data/models/achievement.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  AchievementCategory _selectedCategory = AchievementCategory.gameplay;
  final AchievementProgress _progress = const AchievementProgress();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildCategoryTabs(),
              const SizedBox(height: 16),
              Expanded(child: _buildAchievementsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(10),
            borderRadius: 12,
            onTap: () => Navigator.pop(context),
            child: const Icon(
              LucideIcons.arrowLeft,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Achievements', style: AppTextStyles.headlineMedium),
                Text(
                  '${_progress.totalUnlocked}/${Achievement.allAchievements.length} unlocked',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _progress.completionPercentage,
                  backgroundColor: AppColors.textMuted.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentGold,
                  ),
                  strokeWidth: 4,
                ),
                Text(
                  '${(_progress.completionPercentage * 100).round()}%',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildCategoryTabs() {
    final categories = [
      (AchievementCategory.gameplay, 'Gameplay', LucideIcons.gamepad2),
      (AchievementCategory.streak, 'Streaks', LucideIcons.flame),
      (AchievementCategory.score, 'Scores', LucideIcons.trophy),
      (AchievementCategory.daily, 'Daily', LucideIcons.calendar),
      (AchievementCategory.special, 'Special', LucideIcons.star),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.orbBlue.withValues(alpha: 0.3)
                      : AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.orbBlue
                        : AppColors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      cat.$3,
                      size: 18,
                      color: isSelected
                          ? AppColors.orbBlue
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat.$2,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementsList() {
    final achievements = Achievement.getByCategory(_selectedCategory);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isUnlocked = _progress.isUnlocked(achievement.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AchievementCard(
            achievement: achievement,
            isUnlocked: isUnlocked,
          ),
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: isUnlocked
          ? achievement.rarityColor.withValues(alpha: 0.5)
          : null,
      child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isUnlocked ? achievement.rarityGradient : null,
              color: isUnlocked
                  ? null
                  : AppColors.textMuted.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: achievement.rarityColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? Colors.white : AppColors.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? achievement.rarityColor.withValues(alpha: 0.2)
                            : AppColors.textMuted.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.rarity.name.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isUnlocked
                              ? achievement.rarityColor
                              : AppColors.textMuted,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isUnlocked
                        ? AppColors.textSecondary
                        : AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                ),
                if (achievement.reward != null && isUnlocked) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.gift,
                        size: 14,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reward: ${achievement.reward}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Lock/check icon
          const SizedBox(width: 8),
          Icon(
            isUnlocked ? LucideIcons.checkCircle : LucideIcons.lock,
            color: isUnlocked ? AppColors.orbGreen : AppColors.textMuted,
            size: 24,
          ),
        ],
      ),
    );
  }
}
