import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/games_service.dart';
import '../../../../core/services/mechanic_intro_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import '../../../leaderboard/domain/entities/leaderboard_entry.dart';
import '../../../../core/services/rate_app_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../statistics/data/datasources/statistics_local_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../achievements/presentation/bloc/achievements_bloc.dart';
import '../../../onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../../onboarding/presentation/widgets/tutorial_overlay.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/move_direction.dart';
import '../bloc/game_bloc.dart';
import '../widgets/game_board.dart';
import '../widgets/mechanic_intro_dialog.dart';
import '../widgets/score_display.dart';
import '../widgets/powerup_bar.dart';
import '../widgets/level_complete_dialog.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/screen_shake.dart';
import '../widgets/combo_overlay.dart';
import '../widgets/score_popup.dart';
import '../widgets/particle_effects.dart';
import '../../../levels/domain/entities/level.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';

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
  bool _showTutorial = false;

  bool get _isPremium {
    try {
      final state = context.read<SubscriptionBloc>().state;
      return state is SubscriptionLoaded && state.isPremium;
    } catch (_) {
      return false;
    }
  }

  RestartLevel get _restartEvent => RestartLevel(
        undosAvailable: _isPremium ? 99 : 3,
        hammersAvailable: _isPremium ? 5 : 0,
        shufflesAvailable: _isPremium ? 3 : 0,
        mergeBoostsAvailable: _isPremium ? 3 : 0,
      );

  final _screenShakeKey = GlobalKey<ScreenShakeState>();
  final _comboKey = GlobalKey<ComboOverlayState>();
  final _scorePopupKey = GlobalKey<ScorePopupOverlayState>();
  final _particleKey = GlobalKey<ParticleEffectState>();

  void _handleSwipe(MoveDirection direction) {
    HapticService.instance.light();
    context.read<GameBloc>().add(SwipeMade(direction));
  }

  void _handleBackPress() {
    context.read<GameBloc>().add(const SaveAndExit());
    context.pop();
  }

  void _checkMechanicIntro(BuildContext context) {
    if (_introChecked) return;
    _introChecked = true;

    _checkTutorial();

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

  void _checkTutorial() {
    final onboarding = sl<OnboardingLocalDataSource>();
    if (onboarding.hasCompletedTutorial()) return;

    final levelNum = widget.level.levelNumber;
    if (levelNum >= 1 && levelNum <= 3) {
      setState(() => _showTutorial = true);
    }
  }

  void _onTutorialComplete() {
    final onboarding = sl<OnboardingLocalDataSource>();
    onboarding.saveLastTutorialStep(widget.level.levelNumber);
    if (widget.level.levelNumber >= 3) {
      onboarding.markTutorialCompleted();
    }
    setState(() => _showTutorial = false);
  }

  void _triggerJuiceEffects(GamePlaying state) {
    if (state.lastScoreGained > 0) {
      _scorePopupKey.currentState?.showPopup(state.lastScoreGained);
      sl<SoundService>().playMerge(state.lastScoreGained);
    }

    if (state.comboCount >= 2) {
      _comboKey.currentState?.showCombo(state.comboCount, state.lastScoreGained);
      HapticService.instance.combo();
    }

    if (state.hadBombExplosion) {
      _screenShakeKey.currentState?.shake();
      _particleKey.currentState?.explode();
      HapticService.instance.bomb();
    } else if (state.lastMergeCount > 0) {
      HapticService.instance.merge();
    }

    if (state.lastMergeCount > 0 || state.hadBombExplosion) {
      try {
        sl<StatisticsLocalDataSource>().recordMove(
          mergeCount: state.lastMergeCount,
          hadBombExplosion: state.hadBombExplosion,
          comboCount: state.comboCount,
        );
      } catch (_) {}
    }
  }

  void _showWatchAdForUndo(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.undo_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Out of Undos!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Watch a short ad to earn 1 extra undo',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  sl<AdService>().loadRewardedAd(
                    onRewarded: () {
                      if (mounted) {
                        context.read<GameBloc>().add(const GrantExtraUndo());
                      }
                    },
                  );
                },
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('Watch Ad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('No thanks',
                  style: TextStyle(color: AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
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
            _triggerJuiceEffects(state);
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
              onPanEnd: isPaused
                  ? null
                  : (details) {
                      final velocity = details.velocity.pixelsPerSecond;
                      if (velocity.distance < 100) return;
                      final angle = math.atan2(velocity.dy, velocity.dx);
                      // Determine direction from angle:
                      // right: -45 to 45, down: 45 to 135, left: 135/-135, up: -135 to -45
                      if (angle.abs() <= math.pi / 4) {
                        _handleSwipe(MoveDirection.right);
                      } else if (angle.abs() >= 3 * math.pi / 4) {
                        _handleSwipe(MoveDirection.left);
                      } else if (angle > 0) {
                        _handleSwipe(MoveDirection.down);
                      } else {
                        _handleSwipe(MoveDirection.up);
                      }
                    },
              child: Container(
                decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
                child: SafeArea(
                  child: ScreenShake(
                    key: _screenShakeKey,
                    child: ComboOverlay(
                      key: _comboKey,
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
                                    child: ScorePopupOverlay(
                                      key: _scorePopupKey,
                                      child: Stack(
                                        children: [
                                          GameBoard(
                                            board: session.board,
                                            isHammerMode: _isHammerMode,
                                            onTileTap: _isHammerMode
                                                ? (tileId) {
                                                    HapticService.instance.medium();
                                                    context
                                                        .read<GameBloc>()
                                                        .add(UseHammer(tileId));
                                                    setState(
                                                        () => _isHammerMode = false);
                                                  }
                                                : null,
                                          ),
                                          ParticleEffect(key: _particleKey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PowerUpBar(
                                  session: session,
                                  isHammerMode: _isHammerMode,
                                  isPremiumUser: _isPremium,
                                  onUndo: () {
                                    if (session.undosRemaining <= 0) {
                                      _showWatchAdForUndo(context);
                                      return;
                                    }
                                    HapticService.instance.light();
                                    context.read<GameBloc>().add(const UndoMove());
                                  },
                                  onHammer: () {
                                    if (!_isPremium) {
                                      context.push('/paywall');
                                      return;
                                    }
                                    HapticService.instance.light();
                                    setState(() => _isHammerMode = !_isHammerMode);
                                  },
                                  onShuffle: () {
                                    if (!_isPremium) {
                                      context.push('/paywall');
                                      return;
                                    }
                                    HapticService.instance.medium();
                                    context.read<GameBloc>().add(const UseShuffle());
                                  },
                                  onMergeBoost: () {
                                    if (!_isPremium) {
                                      context.push('/paywall');
                                      return;
                                    }
                                    HapticService.instance.medium();
                                    context.read<GameBloc>().add(const UseMergeBoost());
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          if (isPaused) _PauseOverlay(
                            onBackPress: _handleBackPress,
                            onRestart: () => context.read<GameBloc>().add(_restartEvent),
                          ),
                          if (_showTutorial)
                            Positioned.fill(
                              child: TutorialOverlay(
                                levelNumber: widget.level.levelNumber,
                                onComplete: _onTutorialComplete,
                              ),
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
    } catch (_) {}

    try {
      sl<StatisticsLocalDataSource>().recordLevelCompleted(
        score: state.session.board.score,
        stars: state.stars,
        highestTile: state.session.board.highestTile,
        merges: state.session.board.score ~/ 4,
        moves: state.session.board.moveCount,
        undosUsed: 3 - state.session.undosRemaining,
        bombExplosions: 0,
        bestCombo: 0,
      );
    } catch (_) {}

    _checkRateAppPrompt(state.stars);

    try {
      sl<AnalyticsService>().logLevelCompleted(
        levelId: state.level.id,
        score: state.session.board.score,
        stars: state.stars,
        moves: state.session.board.moveCount,
        highestTile: state.session.board.highestTile,
      );
    } catch (_) {}

    _submitLeaderboardScore(
      context,
      score: state.session.board.score,
      highestTile: state.session.board.highestTile,
    );
  }

  void _checkRateAppPrompt(int stars) {
    final rateService = sl<RateAppService>();
    rateService.recordLevelCompleted(stars: stars);

    if (rateService.shouldPromptForReview()) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) rateService.requestReview();
      });
    }
  }

  void _submitLeaderboardScore(
    BuildContext context, {
    required int score,
    required int highestTile,
  }) {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;
      final user = authState.user;

      LeaderboardMode mode;
      String nativeLeaderboardId;
      if (widget.level.id == 'daily_challenge') {
        mode = LeaderboardMode.daily;
        nativeLeaderboardId = AppConstants.leaderboardDailyId;
      } else if (widget.level.id == 'weekly_challenge') {
        mode = LeaderboardMode.weekly;
        nativeLeaderboardId = AppConstants.leaderboardWeeklyId;
      } else {
        mode = LeaderboardMode.story;
        nativeLeaderboardId = AppConstants.leaderboardStoryId;
      }

      // Submit to Firestore leaderboard
      if (sl.isRegistered<LeaderboardRemoteDataSource>()) {
        sl<LeaderboardRemoteDataSource>().submitScore(
          uid: user.uid,
          displayName: user.username,
          photoUrl: user.photoUrl,
          score: score,
          highestTile: highestTile,
          mode: mode,
        );
      }

      // Submit to native Game Center / Google Play Games
      sl<GamesService>().submitScore(
        score: score,
        leaderboardId: nativeLeaderboardId,
      );
    } catch (_) {}
  }

  void _showLevelComplete(BuildContext context, GameWon state) {
    sl<AdService>().onLevelCompleted(isPremium: _isPremium);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelCompleteDialog(
        score: state.session.board.score,
        stars: state.stars,
        levelNumber: state.level.levelNumber,
        isPremium: _isPremium,
        onUpgrade: !_isPremium
            ? () {
                Navigator.of(context).pop();
                context.push('/paywall');
              }
            : null,
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
          context.read<GameBloc>().add(_restartEvent);
        },
      ),
    );
  }

  void _showGameOver(BuildContext context, GameLost state) {
    try {
      sl<AnalyticsService>().logLevelFailed(
        levelId: state.level.id,
        score: state.session.board.score,
        moves: state.session.board.moveCount,
        highestTile: state.session.board.highestTile,
      );
    } catch (_) {}

    final hasHistory = state.session.moveHistory.isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        score: state.session.board.score,
        highestTile: state.session.board.highestTile,
        isPremium: _isPremium,
        onContinuePremium: _isPremium && hasHistory
            ? () {
                Navigator.of(context).pop();
                context.read<GameBloc>().add(const ContinueAfterLoss());
              }
            : null,
        onWatchAdToContinue: !_isPremium && hasHistory
            ? () {
                Navigator.of(context).pop();
                sl<AdService>().loadRewardedAd(
                  onRewarded: () {
                    if (mounted) {
                      context
                          .read<GameBloc>()
                          .add(const ContinueAfterLoss());
                    }
                  },
                );
              }
            : null,
        onUpgrade: !_isPremium
            ? () {
                Navigator.of(context).pop();
                context.push('/paywall');
              }
            : null,
        onRetry: () {
          Navigator.of(context).pop();
          context.read<GameBloc>().add(_restartEvent);
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
  final VoidCallback onRestart;

  const _PauseOverlay({required this.onBackPress, required this.onRestart});

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
