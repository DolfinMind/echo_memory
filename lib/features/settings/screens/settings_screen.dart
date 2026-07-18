/// Settings screen for Echo Memory
/// Game configuration and preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HapticService _hapticService = HapticService();
  final StorageService _storageService = StorageService();

  bool _hapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = _hapticService.isEnabled;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final hapticEnabled = await _storageService.getHapticEnabled();
    if (mounted) {
      setState(() => _hapticEnabled = hapticEnabled);
      _hapticService.toggleHaptics(hapticEnabled);
    }
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy at a glance'),
        content: const Text(
          'Echo Memory is fully offline. It does not create an account, show '
          'ads, use analytics, or collect or share personal data. Scores, '
          'settings, and progress stay on this device and are removed when '
          'the app data is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Game feedback', [
                          _buildSwitchTile(
                            title: 'Haptic Feedback',
                            subtitle: 'Tactile cues for taps and results',
                            icon: LucideIcons.smartphone,
                            value: _hapticEnabled,
                            onChanged: (value) async {
                              setState(() => _hapticEnabled = value);
                              _hapticService.toggleHaptics(value);
                              await _storageService.setHapticEnabled(value);
                            },
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSection('About', [
                          _buildInfoTile(
                            title: 'Offline edition',
                            value: '2.1.0',
                            icon: LucideIcons.wifiOff,
                          ),
                          _buildActionTile(
                            title: 'Privacy Policy',
                            icon: LucideIcons.shieldCheck,
                            onTap: _showPrivacyPolicy,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
        Text('Settings', style: AppTextStyles.headlineMedium),
      ],
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(color: AppColors.glassBorder, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    ).animate().fadeIn(delay: (100 * children.length).ms);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orbBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.orbBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.orbGreen,
            activeTrackColor: AppColors.orbGreen.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
