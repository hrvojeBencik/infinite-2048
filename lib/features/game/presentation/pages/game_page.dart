import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/mechanic_intro_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import '../../../leaderboard/domain/entities/leaderboard_entry.dart';
import '../../../../core/services/rate_app_service.dart';
import '../../../../core/services/haptic_service.dart';
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
  bool _boardAnimating = false;

  RestartLevel get _restartEvent => RestartLevel(
        undosAvailable: GameConstants.undosPerLevel,
        hammersAvailable: GameConstants.hammersPerLevel,
        shufflesAvailable: GameConstants.shufflesPerLevel,
        mergeBoostsAvailable: GameConstants.mergeBoostsPerLevel,
      );

  final _screenShakeKey = GlobalKey<ScreenShakeState>();
  final _comboKey = GlobalKey<ComboOverlayState>();
  final _scorePopupKey = GlobalKey<ScorePopupOverlayState>();
  final _particleKey = GlobalKey<ParticleEffectState>();

  void _handleSwipe(MoveDirection direction) {
    sl<HapticService>().light();
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
    try { sl<AnalyticsService>().logTutorialCompleted(levelNumber: widget.level.levelNumber); } catch (_) {}
    setState(() => _showTutorial = false);
  }

  void _triggerJuiceEffects(GamePlaying state) {
    if (state.lastScoreGained > 0) {
      _scorePopupKey.currentState?.showPopup(state.lastScoreGained);
      sl<SoundService>().playMerge(state.lastScoreGained);
    }

    if (state.comboCount >= 2) {
      _comboKey.currentState?.showCombo(state.comboCount, state.lastScoreGained);
      sl<HapticService>().combo();
    }

    if (state.hadBombExplosion) {
      _screenShakeKey.currentState?.shake();
      _particleKey.currentState?.explode();
      sl<HapticService>().bomb();
    } else if (state.lastMergeCount > 0) {
      sl<HapticService>().merge();
    }

    // Block swipes during merge animation (ANIM-01)
    if (state.lastMergeCount > 0 || state.hadBombExplosion) {
      _boardAnimating = true;
      Future.delayed(const Duration(milliseconds: 420), () {
        if (mounted) _boardAnimating = false;
      });
    }

    if (state.lastMergeCount > 0 || state.hadBombExplosion) {
      try {
        sl<StatisticsLocalDataSource>().recordMove(
          mergeCount: state.lastMergeCount,
          hadBombExplosion: state.hadBombExplosion,
          comboCount: state.comboCount,
        );
      } catch (e) {
        debugPrint('Failed to record move stats: $e');
      }
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
                        try { sl<AnalyticsService>().logAdWatched(type: AnalyticsAdType.rewardedUndo); } catch (_) {}
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

  // Helper methods to extract session and level from any GameState
  GameSession? _extractSession(GameState state) {
    if (state is GamePlaying) return state.session;
    if (state is GameWon) return state.session;
    if (state is GameLost) return state.session;
    return null;
  }

  Level? _extractLevel(GameState state) {
    if (state is GamePlaying) return state.level;
    if (state is GameWon) return state.level;
    if (state is GameLost) return state.level;
    return null;
  }

  // Zone 1: Header — static per game session, no BlocBuilder needed
  Widget _buildHeaderZone(Level level) {
    return RepaintBoundary(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: _handleBackPress,
          ),
          Expanded(
            child: Text(
              widget.isDailyChallenge ? 'Daily Challenge' : 'Level ${level.levelNumber}',
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
    );
  }

  // Zone 2: Score — rebuilds only when score or moveCount changes
  Widget _buildScoreZone() {
    return RepaintBoundary(
      child: BlocBuilder<GameBloc, GameState>(
        buildWhen: (prev, curr) {
          if (prev is! GamePlaying || curr is! GamePlaying) return true;
          return prev.session.board.score != curr.session.board.score ||
              prev.session.board.moveCount != curr.session.board.moveCount;
        },
        builder: (context, state) {
          final session = _extractSession(state);
          final level = _extractLevel(state);
          if (session == null || level == null) return const SizedBox.shrink();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ScoreDisplay(label: 'Score', value: session.board.score, highlight: true),
              ScoreDisplay(label: 'Target', value: level.targetTileValue),
              ScoreDisplay(label: 'Moves', value: session.board.moveCount),
            ],
          );
        },
      ),
    );
  }

  // Move limit zone — rebuilds only when moveCount changes
  Widget _buildMoveLimitZone(Level level) {
    if (level.moveLimit == null) return const SizedBox.shrink();
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (prev, curr) {
        if (prev is! GamePlaying || curr is! GamePlaying) return true;
        return prev.session.board.moveCount != curr.session.board.moveCount;
      },
      builder: (context, state) {
        final session = _extractSession(state);
        if (session == null) return const SizedBox.shrink();
        return Column(
          children: [
            const SizedBox(height: 8),
            _MoveLimitIndicator(current: session.board.moveCount, max: level.moveLimit!),
          ],
        );
      },
    );
  }

  // Zone 3: Board — rebuilds only when board changes (every valid swipe)
  Widget _buildBoardZone() {
    return Expanded(
      child: Center(
        child: ScorePopupOverlay(
          key: _scorePopupKey,
          child: RepaintBoundary(
            child: BlocBuilder<GameBloc, GameState>(
              buildWhen: (prev, curr) {
                if (prev is! GamePlaying || curr is! GamePlaying) return true;
                return prev.session.board != curr.session.board;
              },
              builder: (context, state) {
                final session = _extractSession(state);
                if (session == null) return const SizedBox.shrink();
                return Stack(
                  children: [
                    GameBoard(
                      board: session.board,
                      isHammerMode: _isHammerMode,
                      onTileTap: _isHammerMode
                          ? (tileId) {
                              sl<HapticService>().medium();
                              context.read<GameBloc>().add(UseHammer(tileId));
                              setState(() => _isHammerMode = false);
                            }
                          : null,
                    ),
                    ParticleEffect(key: _particleKey),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Zone 4: Powerups — rebuilds only when powerup counts change
  Widget _buildPowerupZone() {
    return RepaintBoundary(
      child: BlocBuilder<GameBloc, GameState>(
        buildWhen: (prev, curr) {
          if (prev is! GamePlaying || curr is! GamePlaying) return true;
          return prev.session.undosRemaining != curr.session.undosRemaining ||
              prev.session.hammersRemaining != curr.session.hammersRemaining ||
              prev.session.shufflesRemaining != curr.session.shufflesRemaining ||
              prev.session.mergeBoostsRemaining != curr.session.mergeBoostsRemaining;
        },
        builder: (context, state) {
          final session = _extractSession(state);
          if (session == null) return const SizedBox.shrink();
          return PowerUpBar(
            session: session,
            isHammerMode: _isHammerMode,
            onUndo: () {
              if (session.undosRemaining <= 0) {
                _showWatchAdForUndo(context);
                return;
              }
              sl<HapticService>().light();
              try { sl<AnalyticsService>().logPowerUpUsed(powerUp: AnalyticsPowerUp.undo); } catch (_) {}
              context.read<GameBloc>().add(const UndoMove());
            },
            onHammer: session.hammersRemaining > 0
                ? () {
                    sl<HapticService>().light();
                    if (!_isHammerMode) {
                      try { sl<AnalyticsService>().logPowerUpUsed(powerUp: AnalyticsPowerUp.hammer); } catch (_) {}
                    }
                    setState(() => _isHammerMode = !_isHammerMode);
                  }
                : null,
            onShuffle: session.shufflesRemaining > 0
                ? () {
                    sl<HapticService>().medium();
                    try { sl<AnalyticsService>().logPowerUpUsed(powerUp: AnalyticsPowerUp.shuffle); } catch (_) {}
                    context.read<GameBloc>().add(const UseShuffle());
                  }
                : null,
            onMergeBoost: session.mergeBoostsRemaining > 0
                ? () {
                    sl<HapticService>().medium();
                    try { sl<AnalyticsService>().logPowerUpUsed(powerUp: AnalyticsPowerUp.mergeBoost); } catch (_) {}
                    context.read<GameBloc>().add(const UseMergeBoost());
                  }
                : null,
          );
        },
      ),
    );
  }

  // Pause overlay zone — rebuilds only when pause status changes
  Widget _buildPauseZone() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (prev, curr) {
        if (prev is! GamePlaying || curr is! GamePlaying) return true;
        return prev.session.status != curr.session.status;
      },
      builder: (context, state) {
        final session = _extractSession(state);
        if (session == null) return const SizedBox.shrink();
        final isPaused = session.status == GameStatus.paused;
        if (!isPaused) return const SizedBox.shrink();
        return _PauseOverlay(
          onBackPress: _handleBackPress,
          onRestart: () {
            try { sl<AnalyticsService>().logLevelRestarted(levelId: widget.level.id); } catch (_) {}
            context.read<GameBloc>().add(_restartEvent);
          },
        );
      },
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
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GamePlaying && state.session.board.moveCount == 0) {
            try {
              sl<AnalyticsService>().logLevelStarted(
                levelId: widget.level.id,
                boardSize: widget.level.boardSize,
                targetTile: widget.level.targetTileValue,
                isDailyChallenge: widget.isDailyChallenge,
              );
            } catch (_) {}
          }
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
        child: BlocBuilder<GameBloc, GameState>(
          buildWhen: (prev, curr) {
            // Only rebuild scaffold when transitioning between state types
            return prev.runtimeType != curr.runtimeType;
          },
          builder: (context, state) {
            if (state is! GamePlaying && state is! GameWon && state is! GameLost) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            final level = _extractLevel(state)!;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanEnd: (details) {
                  // Read current pause state directly — safe one-shot read in callback
                  final gameBlocState = context.read<GameBloc>().state;
                  final isPaused = gameBlocState is GamePlaying &&
                      gameBlocState.session.status == GameStatus.paused;
                  if (isPaused || _boardAnimating) return;

                  final velocity = details.velocity.pixelsPerSecond;
                  if (velocity.distance < 100) return;
                  final angle = math.atan2(velocity.dy, velocity.dx);
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
                                  // Zone 1: Header (static per game session)
                                  _buildHeaderZone(level),
                                  const SizedBox(height: 12),
                                  // Zone 2: Score row
                                  _buildScoreZone(),
                                  // Move limit indicator (conditional)
                                  _buildMoveLimitZone(level),
                                  const SizedBox(height: 16),
                                  // Zone 3: Game board
                                  _buildBoardZone(),
                                  const SizedBox(height: 16),
                                  // Zone 4: Power-up bar
                                  _buildPowerupZone(),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                            // Pause overlay zone
                            _buildPauseZone(),
                            // Tutorial overlay (driven by local state)
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
        undosUsed: GameConstants.undosPerLevel - state.session.undosRemaining,
        isDailyChallenge: widget.isDailyChallenge,
      ));
    } catch (e) {
      debugPrint('Failed to track achievements: $e');
    }

    try {
      sl<StatisticsLocalDataSource>().recordLevelCompleted(
        score: state.session.board.score,
        stars: state.stars,
        highestTile: state.session.board.highestTile,
        merges: state.session.board.score ~/ 4,
        moves: state.session.board.moveCount,
        undosUsed: GameConstants.undosPerLevel - state.session.undosRemaining,
        bombExplosions: 0,
        bestCombo: 0,
      );
    } catch (e) {
      debugPrint('Failed to record level stats: $e');
    }

    _checkRateAppPrompt(state.stars);

    try {
      sl<AnalyticsService>().logLevelCompleted(
        levelId: state.level.id,
        score: state.session.board.score,
        stars: state.stars,
        moves: state.session.board.moveCount,
        highestTile: state.session.board.highestTile,
      );
    } catch (e) {
      debugPrint('Failed to log analytics: $e');
    }

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
      if (widget.level.id == 'daily_challenge') {
        mode = LeaderboardMode.daily;
      } else if (widget.level.id == 'weekly_challenge') {
        mode = LeaderboardMode.weekly;
      } else {
        mode = LeaderboardMode.story;
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
    } catch (e) {
      debugPrint('Failed to submit leaderboard score: $e');
    }
  }

  void _showLevelComplete(BuildContext context, GameWon state) {
    sl<AdService>().onLevelCompleted();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => LevelCompleteDialog(
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
    } catch (e) {
      debugPrint('Failed to log level failure: $e');
    }

    final hasHistory = state.session.moveHistory.isNotEmpty;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => GameOverDialog(
        score: state.session.board.score,
        highestTile: state.session.board.highestTile,
        onWatchAdToContinue: hasHistory
            ? () {
                Navigator.of(context).pop();
                sl<AdService>().loadRewardedAd(
                  onRewarded: () {
                    if (mounted) {
                      try {
                        sl<AnalyticsService>().logAdWatched(type: AnalyticsAdType.rewardedContinue);
                        sl<AnalyticsService>().logContinueAfterLoss(source: 'ad', levelId: state.level.id);
                      } catch (_) {}
                      context
                          .read<GameBloc>()
                          .add(const ContinueAfterLoss());
                    }
                  },
                );
              }
            : null,
        onRetry: () {
          Navigator.of(context).pop();
          try { sl<AnalyticsService>().logLevelRestarted(levelId: state.level.id); } catch (_) {}
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
