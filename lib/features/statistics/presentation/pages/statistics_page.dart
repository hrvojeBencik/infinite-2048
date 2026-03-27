import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/datasources/statistics_local_datasource.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late StatisticsLocalDataSource _dataSource;
  late GameStats _stats;

  @override
  void initState() {
    super.initState();
    _dataSource = sl<StatisticsLocalDataSource>();
    _stats = _dataSource.getStats();
    try { sl<AnalyticsService>().logScreenView('statistics'); } catch (_) {}
  }

  void _reload() {
    setState(() => _stats = _dataSource.getStats());
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Statistics',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to reset all statistics? This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _dataSource.resetStats();
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textPrimary,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                        children: [
                          _StatCard(
                            icon: Icons.sports_esports_rounded,
                            iconColor: AppColors.primary,
                            value: '${_stats.totalGamesPlayed}',
                            label: 'Total Games',
                            index: 0,
                          ),
                          _StatCard(
                            icon: Icons.emoji_events_rounded,
                            iconColor: AppColors.secondary,
                            value: '${_stats.levelsCompleted}',
                            label: 'Levels Completed',
                            index: 1,
                          ),
                          _StatCard(
                            icon: Icons.star_rounded,
                            iconColor: AppColors.success,
                            value: '${_stats.totalScore}',
                            label: 'Total Score',
                            index: 2,
                          ),
                          _StatCard(
                            icon: Icons.grid_4x4_rounded,
                            iconColor: AppColors.primaryLight,
                            value: _stats.highestTileEver > 0
                                ? '${_stats.highestTileEver}'
                                : '-',
                            label: 'Highest Tile',
                            index: 3,
                          ),
                          _StatCard(
                            icon: Icons.merge_type_rounded,
                            iconColor: AppColors.zoneGlacier,
                            value: '${_stats.totalMerges}',
                            label: 'Total Merges',
                            index: 4,
                          ),
                          _StatCard(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.zoneInferno,
                            value: '${_stats.bombsTriggered}',
                            label: 'Bombs Triggered',
                            index: 5,
                          ),
                          _StatCard(
                            icon: Icons.trending_up_rounded,
                            iconColor: AppColors.zoneNexus,
                            value: '${_stats.bestComboStreak}',
                            label: 'Best Combo',
                            index: 6,
                          ),
                          _StatCard(
                            icon: Icons.star_outline_rounded,
                            iconColor: AppColors.secondary,
                            value: '${_stats.threeStarLevels}',
                            label: '3-Star Levels',
                            index: 7,
                          ),
                          _StatCard(
                            icon: Icons.directions_rounded,
                            iconColor: AppColors.zoneGenesis,
                            value: '${_stats.totalMoves}',
                            label: 'Total Moves',
                            index: 8,
                          ),
                          _StatCard(
                            icon: Icons.undo_rounded,
                            iconColor: AppColors.textSecondary,
                            value: '${_stats.totalUndosUsed}',
                            label: 'Undos Used',
                            index: 9,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: _confirmReset,
                        child: const Text(
                          'Reset Statistics',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final int index;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.08, duration: 300.ms);
  }
}
