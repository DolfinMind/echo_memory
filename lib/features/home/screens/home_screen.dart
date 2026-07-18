import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../config/constants/game_constants.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/player_stats.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../daily_challenge/screens/daily_challenge_screen.dart';
import '../../game/screens/game_screen.dart';
import '../../lumina/screens/lumina_screen.dart';
import '../../nback/screens/nback_screen.dart';
import '../../practice/screens/practice_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../stream/screens/stream_screen.dart';
import '../widgets/game_mode_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  PlayerStats _stats = const PlayerStats();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _storageService.getPlayerStats();
    if (mounted) setState(() => _stats = stats);
  }

  Future<void> _navigateTo(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        particleCount: 18,
        particleColor: AppColors.orbBlue.withValues(alpha: 0.22),
        child: GameGradientBackground(
          showOverlay: false,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gutter = constraints.maxWidth >= 900 ? 32.0 : 20.0;
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildTopBar(gutter)),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 32),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHero(),
                                const SizedBox(height: 30),
                                const _SectionTitle(
                                  title: 'Choose your focus',
                                  subtitle: 'Every mode works offline.',
                                ),
                                const SizedBox(height: 14),
                                _buildModes(),
                                const SizedBox(height: 24),
                                _buildPrivacyNote(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double gutter) {
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.orbBlue, AppColors.orbPurple],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  LucideIcons.brain,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Echo Memory', style: AppTextStyles.titleMedium),
                    Text(
                      'Free offline edition',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox.square(
                dimension: 48,
                child: IconButton.filledTonal(
                  tooltip: 'Settings',
                  onPressed: () => _navigateTo(const SettingsScreen()),
                  icon: const Icon(LucideIcons.settings, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      borderColor: AppColors.orbBlue.withValues(alpha: 0.28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;
          final copy = _buildHeroCopy(wide);
          final visual = _buildHeroVisual();
          return Padding(
            padding: EdgeInsets.all(wide ? 32 : 24),
            child: wide
                ? Row(
                    children: [
                      Expanded(flex: 3, child: copy),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: visual),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [copy, const SizedBox(height: 28), visual],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCopy(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.orbGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'FOCUS • RECALL • FLOW',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.orbGreen,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Build a stronger\nmemory loop.',
          style: AppTextStyles.displaySmall.copyWith(
            fontSize: wide ? 42 : 34,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Watch a pattern, hold it in mind, then echo it back. '
          'Short sessions, fair scoring, no distractions.',
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(height: 22),
        NeonButton(
          text: 'Start Classic Echo',
          width: wide ? 230 : double.infinity,
          color: AppColors.orbBlue,
          icon: LucideIcons.play,
          onPressed: () => _navigateTo(const DifficultySelectScreen()),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _InlineStat(label: 'High score', value: '${_stats.highScore}'),
            _InlineStat(label: 'Best streak', value: '${_stats.bestStreak}'),
            _InlineStat(label: 'Sessions', value: '${_stats.totalGamesPlayed}'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroVisual() {
    const colors = AppColors.gameOrbs;
    return Semantics(
      label: 'Five memory signals represented by unique colors and icons',
      child: AspectRatio(
        aspectRatio: 1.35,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1020),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLight,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Icon(
                  LucideIcons.waves,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
              ),
              for (var i = 0; i < colors.length; i++)
                Align(
                  alignment: [
                    const Alignment(0, -0.82),
                    const Alignment(0.82, -0.1),
                    const Alignment(0.5, 0.78),
                    const Alignment(-0.5, 0.78),
                    const Alignment(-0.82, -0.1),
                  ][i],
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors[i],
                      boxShadow: [
                        BoxShadow(
                          color: colors[i].withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModes() {
    final modes = <Widget>[
      GameModeCard(
        title: 'Daily Challenge',
        description: 'One seeded run each day. Make it count.',
        icon: LucideIcons.calendarCheck,
        gradient: const LinearGradient(
          colors: [AppColors.orbPurple, Color(0xFF7C3AED)],
        ),
        badge: 'DAILY',
        onTap: () => _navigateTo(const DailyChallengeScreen()),
      ),
      GameModeCard(
        title: 'Practice',
        description: 'No clock. Replay one pattern per round.',
        icon: LucideIcons.graduationCap,
        gradient: const LinearGradient(
          colors: [AppColors.orbGreen, Color(0xFF0F766E)],
        ),
        onTap: () => _navigateTo(const PracticeGameScreen()),
      ),
      GameModeCard(
        title: 'Lumina Matrix',
        description: 'Recall illuminated positions on a growing grid.',
        icon: LucideIcons.layoutGrid,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
        onTap: () => _navigateTo(const LuminaScreen()),
      ),
      GameModeCard(
        title: 'Reflex Match',
        description: 'Decide whether two cards match exactly.',
        icon: LucideIcons.zap,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        onTap: () => _navigateTo(const NBackScreen()),
      ),
      GameModeCard(
        title: 'Echo Stream',
        description: 'Spot the missing symbol in a short visual stream.',
        icon: LucideIcons.waves,
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0369A1)],
        ),
        onTap: () => _navigateTo(const StreamScreen()),
      ),
      GameModeCard(
        title: 'Quantum Flux',
        description: 'Repeat the pattern after every signal moves.',
        icon: LucideIcons.shuffle,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFF9D174D)],
        ),
        badge: 'HARD',
        onTap: () => _navigateTo(
          const GameScreen(
            difficulty: 'quantum',
            settings: {
              'initialSequence': 3,
              'timeLimit': 10,
              'pointMultiplier': 3,
              'lives': 3,
            },
          ),
        ),
      ),
      GameModeCard(
        title: 'Zen Echo',
        description: 'Endless recall without timers or lost lives.',
        icon: LucideIcons.leaf,
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF15803D)],
        ),
        onTap: () => _navigateTo(
          const GameScreen(
            difficulty: 'zen',
            settings: {
              'initialSequence': 3,
              'timeLimit': 0,
              'pointMultiplier': 1,
              'lives': 999,
            },
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 118,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: modes,
        );
      },
    );
  }

  Widget _buildPrivacyNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          LucideIcons.shieldCheck,
          size: 16,
          color: AppColors.orbGreen,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'No ads • No account • No data collection',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameGradientBackground(
        showOverlay: false,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      SizedBox.square(
                        dimension: 48,
                        child: IconButton.filledTonal(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(LucideIcons.arrowLeft, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Classic Echo',
                              style: AppTextStyles.headlineMedium,
                            ),
                            Text(
                              'Choose the pace that feels challenging.',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _difficultyCard(
                    context,
                    id: 'beginner',
                    icon: LucideIcons.sprout,
                    color: AppColors.difficultyBeginner,
                  ),
                  const SizedBox(height: 12),
                  _difficultyCard(
                    context,
                    id: 'expert',
                    icon: LucideIcons.zap,
                    color: AppColors.difficultyExpert,
                  ),
                  const SizedBox(height: 12),
                  _difficultyCard(
                    context,
                    id: 'master',
                    icon: LucideIcons.flame,
                    color: AppColors.difficultyMaster,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _difficultyCard(
    BuildContext context, {
    required String id,
    required IconData icon,
    required Color color,
  }) {
    final difficulty = GameConstants.difficulties[id]!;
    return GlassContainer(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
              difficulty: id,
              settings: {
                'initialSequence': difficulty.initialSequence,
                'timeLimit': difficulty.timeLimit,
                'pointMultiplier': difficulty.pointMultiplier,
                'lives': difficulty.lives,
              },
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surface.withValues(alpha: 0.88),
      borderColor: color.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(difficulty.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(
                  '${difficulty.description} • ${difficulty.timeLimit}s • ${difficulty.lives} lives',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, color: color, size: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppTextStyles.headlineSmall)),
        const SizedBox(width: 12),
        Text(subtitle, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _InlineStat extends StatelessWidget {
  final String label;
  final String value;

  const _InlineStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.labelMedium,
          children: [
            TextSpan(
              text: value,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            TextSpan(text: '  $label'),
          ],
        ),
      ),
    );
  }
}
