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

  const AchievementsLoaded({
    required this.achievements,
    this.dailyChallenge,
  });

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;
  int get totalCount => achievements.length;

  List<Achievement> byCategory(AchievementCategory category) =>
      achievements.where((a) => a.category == category).toList();

  @override
  List<Object?> get props => [achievements, dailyChallenge];
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
  }

  Future<void> _onLoad(
      LoadAchievements event, Emitter<AchievementsState> emit) async {
    emit(AchievementsLoading());
    try {
      final achievements = await repository.getAchievements();
      final daily = await repository.getDailyChallenge();
      emit(AchievementsLoaded(achievements: achievements, dailyChallenge: daily));
    } catch (e) {
      emit(AchievementsLoaded(achievements: const []));
    }
  }

  Future<void> _onTrackProgress(
      TrackProgress event, Emitter<AchievementsState> emit) async {
    await repository.updateAchievementProgress(
        event.achievementId, event.progress);

    final achievements = await repository.getAchievements();
    final updated =
        achievements.where((a) => a.id == event.achievementId).firstOrNull;

    if (updated != null &&
        updated.progressPercentage >= 1.0 &&
        !updated.isUnlocked) {
      await repository.unlockAchievement(event.achievementId);
      final refreshed = await repository.getAchievements();
      final unlocked =
          refreshed.where((a) => a.id == event.achievementId).first;
      emit(AchievementUnlocked(unlocked));
    }

    final all = await repository.getAchievements();
    final daily = await repository.getDailyChallenge();
    emit(AchievementsLoaded(achievements: all, dailyChallenge: daily));
  }
}
