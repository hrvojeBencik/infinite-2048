import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../data/datasources/progression_local_datasource.dart';
import '../../domain/entities/player_profile.dart';
import '../../domain/entities/tile_theme.dart';

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  late ProgressionLocalDataSource _ds;
  late PlayerProfile _profile;

  bool get _isPremium {
    try {
      final state = context.read<SubscriptionBloc>().state;
      return state is SubscriptionLoaded && state.isPremium;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _ds = sl<ProgressionLocalDataSource>();
    _profile = _ds.getProfile();
  }

  void _selectTheme(TileTheme theme) {
    _ds.setActiveTileTheme(theme.id);
    setState(() => _profile = _ds.getProfile());
  }

  bool _isThemeUnlocked(TileTheme theme) {
    if (theme.isPremium) return _isPremium;
    return _profile.unlockedTileThemeIds.contains(theme.id) ||
        _profile.level >= theme.requiredLevel;
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Tile Themes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: TileThemes.all.length,
                  itemBuilder: (context, index) {
                    final theme = TileThemes.all[index];
                    final isUnlocked = _isThemeUnlocked(theme);
                    final isActive = _profile.activeTileThemeId == theme.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        onTap: isUnlocked
                            ? () => _selectTheme(theme)
                            : theme.isPremium
                                ? () => context.push('/paywall')
                                : null,
                        borderColor: isActive
                            ? AppColors.primary
                            : theme.isPremium && !isUnlocked
                                ? AppColors.secondary.withAlpha(40)
                                : isUnlocked
                                    ? AppColors.cardBorder
                                    : AppColors.textTertiary.withAlpha(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            theme.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: isUnlocked
                                                  ? AppColors.textPrimary
                                                  : AppColors.textTertiary,
                                            ),
                                          ),
                                          if (isActive) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'ACTIVE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (theme.isPremium) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                gradient: AppColors.premiumGradient,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'PRO',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF0A0E21),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isUnlocked
                                            ? theme.description
                                            : theme.isPremium
                                                ? 'Premium exclusive'
                                                : 'Unlocks at Level ${theme.requiredLevel}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isUnlocked
                                              ? AppColors.textSecondary
                                              : theme.isPremium
                                                  ? AppColors.secondary.withAlpha(180)
                                                  : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isUnlocked && theme.isPremium)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.premiumGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.lock_rounded,
                                        color: Color(0xFF0A0E21), size: 14),
                                  )
                                else if (!isUnlocked)
                                  Icon(Icons.lock_rounded,
                                      color: AppColors.textTertiary.withAlpha(120),
                                      size: 24),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _TileColorPreview(
                              theme: theme,
                              isUnlocked: isUnlocked,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileColorPreview extends StatelessWidget {
  final TileTheme theme;
  final bool isUnlocked;

  const _TileColorPreview({required this.theme, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final values = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048];

    return SizedBox(
      height: 36,
      child: Row(
        children: values.map((value) {
          final color = theme.colorForValue(value);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isUnlocked ? color : color.withAlpha(60),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
