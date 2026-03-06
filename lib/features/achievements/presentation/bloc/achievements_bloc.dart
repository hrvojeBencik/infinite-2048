import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/repositories/achievements_repository.dart';

// Events
abstract class AchievementsEvent extends Equatable {
  const AchievementsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAchievements extends AchievementsEvent {
  const LoadAchievements();
}

class TrackProgress extends AchievementsEvent {
  final String achievementId;
  final double progress;
  const TrackProgress(this.achievementId, this.progress);
  @override
  List<Object?> get props => [achievementId, progress];
}

class TrackLevelCompletion extends AchievementsEvent {
  final String levelId;
  final int score;
  final int stars;
  final int highestTile;
  final int moveCount;
  final int undosUsed;
  final bool isDailyChallenge;

  const TrackLevelCompletion({
    required this.levelId,
    required this.score,
    required this.stars,
    required this.highestTile,
    required this.moveCount,
    required this.undosUsed,
    this.isDailyChallenge = false,
  });

  @override
  List<Object?> get props => [levelId, score, stars, highestTile, undosUsed];
}

// States
abstract class AchievementsState extends Equatable {
  const AchievementsState();
  @override
  List<Object?> get props => [];
}

class AchievementsInitial extends AchievementsState {}

class AchievementsLoading extends AchievementsState {}

class AchievementsLoaded extends AchievementsState {
  final List<Achievement> achievements;
  final Challenge? dailyChallenge;
  final Challenge? weeklyChallenge;

  const AchievementsLoaded({
    required this.achievements,
    this.dailyChallenge,
    this.weeklyChallenge,
  });

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;
  int get totalCount => achievements.length;

  List<Achievement> byCategory(AchievementCategory category) =>
      achievements.where((a) => a.category == category).toList();

  @override
  List<Object?> get props => [achievements, dailyChallenge, weeklyChallenge];
}

class AchievementUnlocked extends AchievementsState {
  final Achievement achievement;
  const AchievementUnlocked(this.achievement);
  @override
  List<Object?> get props => [achievement];
}

// BLoC
class AchievementsBloc extends Bloc<AchievementsEvent, AchievementsState> {
  final AchievementsRepository repository;

  AchievementsBloc({required this.repository}) : super(AchievementsInitial()) {
    on<LoadAchievements>(_onLoad);
    on<TrackProgress>(_onTrackProgress);
    on<TrackLevelCompletion>(_onTrackLevelCompletion);
  }

  Future<void> _onLoad(
      LoadAchievements event, Emitter<AchievementsState> emit) async {
    emit(AchievementsLoading());
    try {
      final achievements = await repository.getAchievements();
      final daily = await repository.getDailyChallenge();
      final weekly = await repository.getWeeklyChallenge();
      emit(AchievementsLoaded(
        achievements: achievements,
        dailyChallenge: daily,
        weeklyChallenge: weekly,
      ));
    } catch (e) {
      emit(AchievementsLoaded(achievements: const []));
    }
  }

  Future<void> _onTrackProgress(
      TrackProgress event, Emitter<AchievementsState> emit) async {
    await _updateAndCheckUnlock(event.achievementId, event.progress, emit);
    await _emitLoaded(emit);
  }

  Future<void> _onTrackLevelCompletion(
      TrackLevelCompletion event, Emitter<AchievementsState> emit) async {
    final achievements = await repository.getAchievements();

    // first_steps: Complete your first level (target: 1)
    final firstSteps = achievements.firstWhere((a) => a.id == 'first_steps');
    await _updateAndCheckUnlock(
        'first_steps', firstSteps.progress + 1, emit);

    // halfway_there: Complete 25 levels (target: 25)
    final halfway = achievements.firstWhere((a) => a.id == 'halfway_there');
    await _updateAndCheckUnlock(
        'halfway_there', halfway.progress + 1, emit);

    // infinite_seeker: Complete all 50 levels (target: 50)
    final seeker = achievements.firstWhere((a) => a.id == 'infinite_seeker');
    await _updateAndCheckUnlock(
        'infinite_seeker', seeker.progress + 1, emit);

    // perfectionist: Earn 3 stars on 10 levels (target: 10)
    if (event.stars >= 3) {
      final perfectionist = achievements.firstWhere((a) => a.id == 'perfectionist');
      await _updateAndCheckUnlock(
          'perfectionist', perfectionist.progress + 1, emit);
    }

    // no_crutch: Complete 5 levels without using undo (target: 5)
    if (event.undosUsed == 0) {
      final noCrutch = achievements.firstWhere((a) => a.id == 'no_crutch');
      await _updateAndCheckUnlock(
          'no_crutch', noCrutch.progress + 1, emit);
    }

    // tile_titan: Create an 8192 tile (target: 1)
    if (event.highestTile >= 8192) {
      await _updateAndCheckUnlock('tile_titan', 1, emit);
    }

    // zone_conqueror: Track levels in a zone
    final zoneId = event.levelId.split('_').first;
    final zoneLevelCount = _zoneLevelCounts[zoneId] ?? 10;
    final conqueror = achievements.firstWhere((a) => a.id == 'zone_conqueror');
    final zoneCompletions = await repository.getCompletedLevelsInZone(zoneId);
    if (zoneCompletions >= zoneLevelCount && !conqueror.isUnlocked) {
      await _updateAndCheckUnlock(
          'zone_conqueror', conqueror.targetValue, emit);
    }

    // daily_dedication: Track daily play streak
    if (event.isDailyChallenge) {
      final daily = await repository.getDailyChallenge();
      if (daily != null && !daily.isCompleted) {
        await repository.completeDailyChallenge(daily.id, event.score);
      }
    }

    await _emitLoaded(emit);
  }

  Future<void> _updateAndCheckUnlock(
      String achievementId, double progress, Emitter<AchievementsState> emit) async {
    await repository.updateAchievementProgress(achievementId, progress);

    final achievements = await repository.getAchievements();
    final updated =
        achievements.where((a) => a.id == achievementId).firstOrNull;

    if (updated != null &&
        updated.progressPercentage >= 1.0 &&
        !updated.isUnlocked) {
      await repository.unlockAchievement(achievementId);
    }
  }

  Future<void> _emitLoaded(Emitter<AchievementsState> emit) async {
    final all = await repository.getAchievements();
    final daily = await repository.getDailyChallenge();
    final weekly = await repository.getWeeklyChallenge();
    emit(AchievementsLoaded(
      achievements: all,
      dailyChallenge: daily,
      weeklyChallenge: weekly,
    ));
  }

  static const _zoneLevelCounts = {
    'genesis': 10,
    'inferno': 10,
    'glacier': 10,
    'nexus': 10,
    'void': 10,
  };
}
