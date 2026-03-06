import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import '../../../leaderboard/domain/entities/leaderboard_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../game/domain/entities/game_session.dart';
import '../../../game/domain/entities/move_direction.dart';
import '../../../game/presentation/widgets/game_board.dart';
import '../../../game/presentation/widgets/score_display.dart';
import '../../../game/presentation/widgets/screen_shake.dart';
import '../../../game/presentation/widgets/combo_overlay.dart';
import '../../../game/presentation/widgets/score_popup.dart';
import '../../../game/presentation/widgets/particle_effects.dart';
import '../bloc/endless_bloc.dart';

class EndlessGamePage extends StatefulWidget {
  const EndlessGamePage({super.key});

  @override
  State<EndlessGamePage> createState() => _EndlessGamePageState();
}

class _EndlessGamePageState extends State<EndlessGamePage> {
  final _screenShakeKey = GlobalKey<ScreenShakeState>();
  final _comboKey = GlobalKey<ComboOverlayState>();
  final _scorePopupKey = GlobalKey<ScorePopupOverlayState>();
  final _particleKey = GlobalKey<ParticleEffectState>();

  void _handleSwipe(MoveDirection direction) {
    HapticService.instance.light();
    context.read<EndlessBloc>().add(EndlessSwipe(direction));
  }

  void _handleBackPress() {
    context.read<EndlessBloc>().add(const EndlessSaveAndExit());
    context.pop();
  }

  void _triggerJuiceEffects(EndlessPlaying state) {
    if (state.lastScoreGained > 0) {
      _scorePopupKey.currentState?.showPopup(state.lastScoreGained);
    }

    if (state.comboCount >= 2) {
      _comboKey.currentState
          ?.showCombo(state.comboCount, state.lastScoreGained);
      HapticService.instance.combo();
    }

    if (state.hadBombExplosion) {
      _screenShakeKey.currentState?.shake();
      _particleKey.currentState?.explode();
      HapticService.instance.bomb();
    } else if (state.lastMergeCount > 0) {
      HapticService.instance.merge();
    }
  }

  void _showGameOver(BuildContext context, EndlessGameOver state) {
    try {
      sl<AnalyticsService>().logEndlessGameOver(
        score: state.session.board.score,
        moves: state.session.board.moveCount,
        highestTile: state.session.board.highestTile,
        isNewRecord: state.isNewRecord,
      );
    } catch (_) {}

    _submitEndlessScore(
      context,
      score: state.session.board.score,
      highestTile: state.session.board.highestTile,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EndlessGameOverDialog(
        score: state.session.board.score,
        highestTile: state.session.board.highestTile,
        highScore: state.highScore,
        moves: state.session.board.moveCount,
        isNewRecord: state.isNewRecord,
        onRestart: () {
          Navigator.of(context).pop();
          context.read<EndlessBloc>().add(const EndlessRestart());
        },
        onExit: () {
          Navigator.of(context).pop();
          context.pop();
        },
      ),
    );
  }

  void _submitEndlessScore(
    BuildContext context, {
    required int score,
    required int highestTile,
  }) {
    if (!sl.isRegistered<LeaderboardRemoteDataSource>()) return;
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;
      final user = authState.user;
      sl<LeaderboardRemoteDataSource>().submitScore(
        uid: user.uid,
        displayName: user.displayName ?? 'Player',
        photoUrl: user.photoUrl,
        score: score,
        highestTile: highestTile,
        mode: LeaderboardMode.endless,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: BlocConsumer<EndlessBloc, EndlessState>(
        listener: (context, state) {
          if (state is EndlessPlaying) {
            _triggerJuiceEffects(state);
          }
          if (state is EndlessGameOver) {
            _showGameOver(context, state);
          }
        },
        builder: (context, state) {
          if (state is! EndlessPlaying && state is! EndlessGameOver) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final session = state is EndlessPlaying
              ? state.session
              : (state as EndlessGameOver).session;

          final highScore = state is EndlessPlaying
              ? state.highScore
              : (state as EndlessGameOver).highScore;

          final isPaused = session.status == GameStatus.paused;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: isPaused
                  ? null
                  : (details) {
                      if (details.primaryVelocity == null) return;
                      if (details.primaryVelocity! > 0) {
                        _handleSwipe(MoveDirection.right);
                      } else {
                        _handleSwipe(MoveDirection.left);
                      }
                    },
              onVerticalDragEnd: isPaused
                  ? null
                  : (details) {
                      if (details.primaryVelocity == null) return;
                      if (details.primaryVelocity! > 0) {
                        _handleSwipe(MoveDirection.down);
                      } else {
                        _handleSwipe(MoveDirection.up);
                      }
                    },
              child: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.backgroundGradient),
                child: SafeArea(
                  child: ScreenShake(
                    key: _screenShakeKey,
                    child: ComboOverlay(
                      key: _comboKey,
                      child: Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: AppColors.textPrimary),
                                      onPressed: _handleBackPress,
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'Endless Mode',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.pause_rounded,
                                          color: AppColors.textPrimary),
                                      onPressed: () => context
                                          .read<EndlessBloc>()
                                          .add(const EndlessPause()),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ScoreDisplay(
                                      label: 'Score',
                                      value: session.board.score,
                                      highlight: true,
                                    ),
                                    ScoreDisplay(
                                      label: 'Best',
                                      value: highScore,
                                    ),
                                    ScoreDisplay(
                                      label: 'Moves',
                                      value: session.board.moveCount,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Center(
                                    child: ScorePopupOverlay(
                                      key: _scorePopupKey,
                                      child: Stack(
                                        children: [
                                          GameBoard(board: session.board),
                                          ParticleEffect(key: _particleKey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _EndlessBottomBar(
                                  undosRemaining: session.undosRemaining,
                                  highestTile: session.board.highestTile,
                                  onUndo: session.undosRemaining > 0 &&
                                          session.moveHistory.isNotEmpty
                                      ? () {
                                          HapticService.instance.light();
                                          context
                                              .read<EndlessBloc>()
                                              .add(const EndlessUndo());
                                        }
                                      : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          if (isPaused)
                            _EndlessPauseOverlay(
                              onResume: () => context
                                  .read<EndlessBloc>()
                                  .add(const EndlessResume()),
                              onRestart: () => context
                                  .read<EndlessBloc>()
                                  .add(const EndlessRestart()),
                              onQuit: _handleBackPress,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EndlessBottomBar extends StatelessWidget {
  final int undosRemaining;
  final int highestTile;
  final VoidCallback? onUndo;

  const _EndlessBottomBar({
    required this.undosRemaining,
    required this.highestTile,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grid_4x4_rounded,
                  size: 18, color: AppColors.secondary.withAlpha(200)),
              const SizedBox(width: 8),
              Text(
                '$highestTile',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onUndo,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: onUndo != null
                  ? AppColors.primary.withAlpha(30)
                  : AppColors.surface.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: onUndo != null
                    ? AppColors.primary.withAlpha(80)
                    : AppColors.cardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.undo_rounded,
                  size: 18,
                  color: onUndo != null
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$undosRemaining',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onUndo != null
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EndlessGameOverDialog extends StatelessWidget {
  final int score;
  final int highestTile;
  final int highScore;
  final int moves;
  final bool isNewRecord;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _EndlessGameOverDialog({
    required this.score,
    required this.highestTile,
    required this.highScore,
    required this.moves,
    required this.isNewRecord,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isNewRecord
                ? AppColors.secondary.withAlpha(80)
                : AppColors.error.withAlpha(60),
          ),
          boxShadow: [
            BoxShadow(
              color: isNewRecord
                  ? AppColors.secondary.withAlpha(20)
                  : AppColors.error.withAlpha(20),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNewRecord) ...[
              Icon(Icons.emoji_events_rounded,
                      size: 56, color: AppColors.secondary)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(
                      begin: const Offset(0, 0),
                      curve: Curves.elasticOut,
                      duration: 600.ms),
              const SizedBox(height: 8),
              Text(
                'NEW RECORD!',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 200.ms),
            ] else ...[
              Icon(Icons.all_inclusive_rounded,
                      size: 56, color: AppColors.textTertiary.withAlpha(180))
                  .animate()
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(label: 'Score', value: '$score'),
                _Stat(label: 'Best Tile', value: '$highestTile'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(label: 'Moves', value: '$moves'),
                _Stat(label: 'High Score', value: '$highScore'),
              ],
            ),
            const SizedBox(height: 28),
            AnimatedButton(
              onPressed: onRestart,
              gradient: AppColors.primaryGradient,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onExit,
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndlessPauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const _EndlessPauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withAlpha(220),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outline_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: onResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'RESUME',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: onRestart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'RESTART',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: TextButton(
                onPressed: onQuit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textTertiary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'QUIT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
