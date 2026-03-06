import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../app/di.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../achievements/domain/repositories/achievements_repository.dart';
import '../../../achievements/presentation/bloc/achievements_bloc.dart';
import '../../../game/domain/entities/special_tile_type.dart';
import '../../../levels/data/datasources/levels_local_datasource.dart';
import '../../../levels/domain/entities/level.dart';
import '../../../onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../../progression/data/datasources/progression_local_datasource.dart';

class DevOptionsPage extends StatefulWidget {
  const DevOptionsPage({super.key});

  @override
  State<DevOptionsPage> createState() => _DevOptionsPageState();
}

class _DevOptionsPageState extends State<DevOptionsPage> {
  int _sandboxBoardSize = 4;
  int _sandboxTarget = 2048;
  int _sandboxUndos = 99;
  int _sandboxHammers = 10;
  int _sandboxShuffles = 10;
  final Map<SpecialTileType, double> _sandboxSpawnRates = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.bug_report_rounded,
                        color: AppColors.warning, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Dev Options',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.warning.withAlpha(60)),
                      ),
                      child: const Text(
                        'DEBUG',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('QUICK LEVEL JUMP'),
                      _buildLevelJumpSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('SANDBOX MODE'),
                      _buildSandboxSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('DATA MANAGEMENT'),
                      _buildDataSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('ACHIEVEMENTS'),
                      _buildAchievementsSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('MECHANIC INTROS'),
                      _buildMechanicIntroSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('PROGRESSION'),
                      _buildProgressionSection(),
                      const SizedBox(height: 32),
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

  Widget _buildLevelJumpSection() {
    final ds = sl<LevelsLocalDataSource>();
    final zones = ds.getZones();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jump directly to any level:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ...zones.map((zone) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: zone.levels.map((level) {
                    return _LevelChip(
                      level: level,
                      onTap: () => _jumpToLevel(level),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSandboxSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create a custom game with any parameters:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'Board Size',
            value: _sandboxBoardSize,
            min: 3,
            max: 8,
            onChanged: (v) => setState(() => _sandboxBoardSize = v),
          ),
          _SliderRow(
            label: 'Target Tile',
            value: _sandboxTarget,
            values: const [16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192],
            onChangedIndex: (v) => setState(() => _sandboxTarget = v),
          ),
          _SliderRow(
            label: 'Undos',
            value: _sandboxUndos,
            min: 0,
            max: 99,
            onChanged: (v) => setState(() => _sandboxUndos = v),
          ),
          _SliderRow(
            label: 'Hammers',
            value: _sandboxHammers,
            min: 0,
            max: 99,
            onChanged: (v) => setState(() => _sandboxHammers = v),
          ),
          _SliderRow(
            label: 'Shuffles',
            value: _sandboxShuffles,
            min: 0,
            max: 99,
            onChanged: (v) => setState(() => _sandboxShuffles = v),
          ),
          const SizedBox(height: 12),
          const Text(
            'Special tile spawn rates:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildSpawnRateToggles(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchSandbox,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text(
                'LAUNCH SANDBOX',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpawnRateToggles() {
    final types = [
      (SpecialTileType.bomb, 'Bomb', Icons.local_fire_department_rounded,
          Colors.red),
      (SpecialTileType.ice, 'Ice', Icons.ac_unit_rounded, Colors.cyan),
      (SpecialTileType.multiplier, 'Multiplier', Icons.flash_on_rounded,
          AppColors.secondary),
      (SpecialTileType.wildcard, 'Wildcard', Icons.star_rounded,
          AppColors.primary),
    ];

    return types.map((t) {
      final rate = _sandboxSpawnRates[t.$1] ?? 0.0;
      final active = rate > 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (active) {
                    _sandboxSpawnRates.remove(t.$1);
                  } else {
                    _sandboxSpawnRates[t.$1] = 0.15;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? t.$4.withAlpha(30) : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: active ? t.$4.withAlpha(80) : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.$3, size: 16, color: active ? t.$4 : AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      t.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? t.$4 : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: rate,
                  min: 0.05,
                  max: 0.5,
                  divisions: 9,
                  activeColor: t.$4,
                  inactiveColor: t.$4.withAlpha(30),
                  label: '${(rate * 100).round()}%',
                  onChanged: (v) {
                    setState(() => _sandboxSpawnRates[t.$1] = v);
                  },
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${(rate * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: t.$4,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDataSection() {
    return GlassCard(
      child: Column(
        children: [
          _DevActionTile(
            icon: Icons.delete_sweep_rounded,
            iconColor: AppColors.error,
            title: 'Reset All Progress',
            subtitle: 'Clears levels, stars, saved games',
            onTap: () => _confirmAction(
              'Reset all level progress?',
              () async {
                await Hive.box(AppConstants.hiveLevelProgressBox).clear();
                await Hive.box(AppConstants.hiveGameStateBox).clear();
                _showSnack('Level progress reset');
              },
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          _DevActionTile(
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.secondary,
            title: 'Reset Achievements',
            subtitle: 'Clears all achievement progress',
            onTap: () => _confirmAction(
              'Reset all achievements?',
              () async {
                final box = Hive.box(AppConstants.hiveAchievementsBox);
                final keysToRemove = box.keys
                    .where((k) => !k.toString().startsWith('daily_completed'))
                    .toList();
                for (final key in keysToRemove) {
                  await box.delete(key);
                }
                if (mounted) {
                  context.read<AchievementsBloc>().add(const LoadAchievements());
                }
                _showSnack('Achievements reset');
              },
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          _DevActionTile(
            icon: Icons.today_rounded,
            iconColor: AppColors.zoneGlacier,
            title: 'Reset Daily Challenge',
            subtitle: 'Allows replaying today\'s challenge',
            onTap: () => _confirmAction(
              'Reset today\'s daily challenge?',
              () async {
                final box = Hive.box(AppConstants.hiveAchievementsBox);
                final now = DateTime.now();
                final key =
                    'daily_completed_${now.year}_${now.month}_${now.day}';
                await box.delete(key);
                if (mounted) {
                  context.read<AchievementsBloc>().add(const LoadAchievements());
                }
                _showSnack('Daily challenge reset');
              },
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          _DevActionTile(
            icon: Icons.star_rounded,
            iconColor: AppColors.zoneNexus,
            title: 'Complete All Levels (3 stars)',
            subtitle: 'Marks every level as completed',
            onTap: () => _confirmAction(
              'Mark all levels as complete?',
              () async {
                final ds = sl<LevelsLocalDataSource>();
                final zones = ds.getZones();
                for (final zone in zones) {
                  for (final level in zone.levels) {
                    await ds.saveLevelProgress(
                      levelId: level.id,
                      score: level.starThreshold3,
                      stars: 3,
                    );
                  }
                }
                _showSnack('All levels completed with 3 stars');
              },
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          _DevActionTile(
            icon: Icons.cleaning_services_rounded,
            iconColor: AppColors.error,
            title: 'Nuclear Reset',
            subtitle: 'Wipes ALL Hive data',
            onTap: () => _confirmAction(
              'This will wipe EVERYTHING. Are you sure?',
              () async {
                await Hive.box(AppConstants.hiveLevelProgressBox).clear();
                await Hive.box(AppConstants.hiveGameStateBox).clear();
                await Hive.box(AppConstants.hiveAchievementsBox).clear();
                await Hive.box(AppConstants.hiveSettingsBox).clear();
                if (mounted) {
                  context.read<AchievementsBloc>().add(const LoadAchievements());
                }
                _showSnack('All data wiped');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return GlassCard(
      child: Column(
        children: [
          _DevActionTile(
            icon: Icons.lock_open_rounded,
            iconColor: AppColors.success,
            title: 'Unlock All Achievements',
            subtitle: 'Instantly unlocks every achievement',
            onTap: () => _confirmAction(
              'Unlock all achievements?',
              () async {
                final bloc = context.read<AchievementsBloc>();
                final achievements =
                    await sl<AchievementsRepository>().getAchievements();
                for (final a in achievements) {
                  bloc.add(TrackProgress(a.id, a.targetValue));
                }
                _showSnack('All achievements unlocked');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicIntroSection() {
    return GlassCard(
      child: Column(
        children: [
          _DevActionTile(
            icon: Icons.replay_rounded,
            iconColor: AppColors.primary,
            title: 'Reset Mechanic Intros',
            subtitle: 'Re-show special tile tutorials',
            onTap: () async {
              final box = Hive.box(AppConstants.hiveSettingsBox);
              for (final type in SpecialTileType.values) {
                await box.delete('mechanic_seen_${type.name}');
              }
              _showSnack('Mechanic intros reset');
            },
          ),
          const Divider(color: AppColors.divider, height: 1),
          _DevActionTile(
            icon: Icons.school_rounded,
            iconColor: AppColors.zoneGlacier,
            title: 'Reset Tutorial',
            subtitle: 'Re-show onboarding tutorial steps',
            onTap: () async {
              await sl<OnboardingLocalDataSource>().resetTutorial();
              _showSnack('Tutorial reset');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionSection() {
    return GlassCard(
      child: Column(
        children: [
          _DevActionTile(
            icon: Icons.add_circle_outline_rounded,
            iconColor: AppColors.success,
            title: 'Add 500 XP',
            subtitle: 'Grant XP for testing level-ups',
            onTap: () async {
              await sl<ProgressionLocalDataSource>().addXp(500);
              _showSnack('Added 500 XP');
            },
          ),
          const Divider(color: AppColors.divider, height: 1),
          _DevActionTile(
            icon: Icons.restart_alt_rounded,
            iconColor: AppColors.error,
            title: 'Reset Progression',
            subtitle: 'Reset XP, themes, and streak',
            onTap: () => _confirmAction(
              'Reset all progression data?',
              () async {
                final box = Hive.box(AppConstants.hiveSettingsBox);
                await box.delete('player_profile');
                _showSnack('Progression reset');
              },
            ),
          ),
        ],
      ),
    );
  }

  void _jumpToLevel(Level level) {
    context.push('/dev/game/${level.id}');
  }

  void _launchSandbox() {
    context.push('/dev/sandbox', extra: {
      'boardSize': _sandboxBoardSize,
      'target': _sandboxTarget,
      'undos': _sandboxUndos,
      'hammers': _sandboxHammers,
      'shuffles': _sandboxShuffles,
      'spawnRates': Map<SpecialTileType, double>.from(_sandboxSpawnRates),
    });
  }

  void _confirmAction(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          message,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Confirm',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final Level level;
  final VoidCallback onTap;

  const _LevelChip({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final completed = level.isCompleted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: completed
              ? AppColors.success.withAlpha(30)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: completed
                ? AppColors.success.withAlpha(80)
                : AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            '${level.levelNumber}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: completed ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DevActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DevActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textTertiary, size: 20),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int? min;
  final int? max;
  final List<int>? values;
  final ValueChanged<int>? onChanged;
  final ValueChanged<int>? onChangedIndex;

  const _SliderRow({
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.values,
    this.onChanged,
    this.onChangedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: values != null
                ? Slider(
                    value: values!.indexOf(value).clamp(0, values!.length - 1).toDouble(),
                    min: 0,
                    max: (values!.length - 1).toDouble(),
                    divisions: values!.length - 1,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withAlpha(30),
                    onChanged: (v) {
                      onChangedIndex?.call(values![v.round()]);
                    },
                  )
                : Slider(
                    value: value.toDouble(),
                    min: (min ?? 0).toDouble(),
                    max: (max ?? 10).toDouble(),
                    divisions: (max ?? 10) - (min ?? 0),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withAlpha(30),
                    onChanged: (v) => onChanged?.call(v.round()),
                  ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
