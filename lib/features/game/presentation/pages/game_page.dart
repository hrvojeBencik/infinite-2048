import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../core/services/mechanic_intro_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../achievements/presentation/bloc/achievements_bloc.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/move_direction.dart';
import '../bloc/game_bloc.dart';
import '../widgets/game_board.dart';
import '../widgets/mechanic_intro_dialog.dart';
import '../widgets/score_display.dart';
import '../widgets/powerup_bar.dart';
import '../widgets/level_complete_dialog.dart';
import '../widgets/game_over_dialog.dart';
import '../../../levels/domain/entities/level.dart';

class GamePage extends StatefulWidget {
  final Level level;
  final bool isDailyChallenge;

  const GamePage({super.key, required this.level, this.isDailyChallenge = false});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _isHammerMode = false;
  bool _introChecked = false;

  void _handleSwipe(MoveDirection direction) {
    HapticFeedback.lightImpact();
    context.read<GameBloc>().add(SwipeMade(direction));
  }

  void _handleBackPress() {
    context.read<GameBloc>().add(const SaveAndExit());
    context.pop();
  }

  void _checkMechanicIntro(BuildContext context) {
    if (_introChecked) return;
    _introChecked = true;

    final introService = sl<MechanicIntroService>();
    final unseen = introService.getUnseenMechanicsForLevel(widget.level);

    if (unseen.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameBloc>().add(const PauseGame());
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.background.withAlpha(180),
        builder: (_) => MechanicIntroDialog(
          newMechanics: unseen,
          onDismiss: () {
            Navigator.of(context).pop();
            introService.markSeen(unseen);
            context.read<GameBloc>().add(const ResumeFromPause());
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GamePlaying) {
            _checkMechanicIntro(context);
          }
          if (state is GameWon) {
            _trackAchievements(context, state);
            _showLevelComplete(context, state);
          } else if (state is GameLost) {
            _showGameOver(context, state);
          }
        },
        builder: (context, state) {
          if (state is! GamePlaying && state is! GameWon && state is! GameLost) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }

          final session = state is GamePlaying
              ? state.session
              : state is GameWon
                  ? state.session
                  : (state as GameLost).session;

          final level = state is GamePlaying
              ? state.level
              : state is GameWon
                  ? state.level
                  : (state as GameLost).level;

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
                decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded,
                                      color: AppColors.textPrimary),
                                  onPressed: _handleBackPress,
                                ),
                                Expanded(
                                  child: Text(
                                    widget.isDailyChallenge
                                        ? 'Daily Challenge'
                                        : 'Level ${level.levelNumber}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.pause_rounded,
                                      color: AppColors.textPrimary),
                                  onPressed: () =>
                                      context.read<GameBloc>().add(const PauseGame()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ScoreDisplay(
                                    label: 'Score',
                                    value: session.board.score,
                                    highlight: true),
                                ScoreDisplay(
                                    label: 'Target', value: level.targetTileValue),
                                ScoreDisplay(
                                    label: 'Moves', value: session.board.moveCount),
                              ],
                            ),
                            if (level.moveLimit != null) ...[
                              const SizedBox(height: 8),
                              _MoveLimitIndicator(
                                current: session.board.moveCount,
                                max: level.moveLimit!,
                              ),
                            ],
                            const SizedBox(height: 16),
                            Expanded(
                              child: Center(
                                child: GameBoard(
                                  board: session.board,
                                  isHammerMode: _isHammerMode,
                                  onTileTap: _isHammerMode
                                      ? (tileId) {
                                          HapticFeedback.mediumImpact();
                                          context.read<GameBloc>().add(UseHammer(tileId));
                                          setState(() => _isHammerMode = false);
                                        }
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            PowerUpBar(
                              session: session,
                              isHammerMode: _isHammerMode,
                              onUndo: () {
                                HapticFeedback.lightImpact();
                                context.read<GameBloc>().add(const UndoMove());
                              },
                              onHammer: () {
                                HapticFeedback.lightImpact();
                                setState(() => _isHammerMode = !_isHammerMode);
                              },
                              onShuffle: () {
                                HapticFeedback.mediumImpact();
                                context.read<GameBloc>().add(const UseShuffle());
                              },
                              onMergeBoost: () {},
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      if (isPaused) _PauseOverlay(onBackPress: _handleBackPress),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _trackAchievements(BuildContext context, GameWon state) {
    try {
      final bloc = context.read<AchievementsBloc>();
      bloc.add(TrackLevelCompletion(
        levelId: state.level.id,
        score: state.session.board.score,
        stars: state.stars,
        highestTile: state.session.board.highestTile,
        moveCount: state.session.board.moveCount,
        undosUsed: 3 - state.session.undosRemaining,
        isDailyChallenge: widget.isDailyChallenge,
      ));
    } catch (_) {
      // AchievementsBloc not available in tree (e.g. not provided)
    }
  }

  void _showLevelComplete(BuildContext context, GameWon state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelCompleteDialog(
        score: state.session.board.score,
        stars: state.stars,
        levelNumber: state.level.levelNumber,
        onNextLevel: () {
          Navigator.of(context).pop();
          context.pop('next');
        },
        onBackToLevels: () {
          Navigator.of(context).pop();
          context.pop();
        },
        onReplay: () {
          Navigator.of(context).pop();
          context.read<GameBloc>().add(const RestartLevel());
        },
      ),
    );
  }

  void _showGameOver(BuildContext context, GameLost state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        score: state.session.board.score,
        highestTile: state.session.board.highestTile,
        onRetry: () {
          Navigator.of(context).pop();
          context.read<GameBloc>().add(const RestartLevel());
        },
        onBackToLevels: () {
          Navigator.of(context).pop();
          context.pop();
        },
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onBackPress;

  const _PauseOverlay({required this.onBackPress});

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
                onPressed: () =>
                    context.read<GameBloc>().add(const ResumeFromPause()),
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
                onPressed: () {
                  context.read<GameBloc>().add(const RestartLevel());
                },
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
                onPressed: onBackPress,
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

class _MoveLimitIndicator extends StatelessWidget {
  final int current;
  final int max;

  const _MoveLimitIndicator({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final progress = (current / max).clamp(0.0, 1.0);
    final color = progress > 0.8 ? AppColors.error : AppColors.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Moves: $current / $max',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
