import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/game_bloc.dart';
import '../widgets/game_board.dart';
import '../widgets/score_display.dart';
import '../widgets/powerup_bar.dart';
import '../widgets/level_complete_dialog.dart';
import '../widgets/game_over_dialog.dart';
import '../../../levels/domain/entities/level.dart';

class GamePage extends StatefulWidget {
  final Level level;

  const GamePage({super.key, required this.level});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _isHammerMode = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameWon) {
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

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Top bar
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Level ${level.levelNumber}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause_rounded, color: AppColors.textPrimary),
                          onPressed: () => context.read<GameBloc>().add(const PauseGame()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Score and target
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ScoreDisplay(label: 'Score', value: session.board.score, highlight: true),
                        ScoreDisplay(label: 'Target', value: level.targetTileValue),
                        ScoreDisplay(label: 'Moves', value: session.board.moveCount),
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
                    // Game board
                    Expanded(
                      child: Center(
                        child: GameBoard(
                          board: session.board,
                          isHammerMode: _isHammerMode,
                          onSwipe: (direction) {
                            HapticFeedback.lightImpact();
                            context.read<GameBloc>().add(SwipeMade(direction));
                          },
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
                    // Power-ups
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
            ),
          ),
        );
      },
    );
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
