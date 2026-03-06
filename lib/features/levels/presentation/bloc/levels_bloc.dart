import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/levels_repository.dart';

// Events
abstract class LevelsEvent extends Equatable {
  const LevelsEvent();

  @override
  List<Object?> get props => [];
}

class LoadZones extends LevelsEvent {
  const LoadZones();
}

class LoadLevelsForZone extends LevelsEvent {
  final String zoneId;
  const LoadLevelsForZone(this.zoneId);

  @override
  List<Object?> get props => [zoneId];
}

class RefreshProgress extends LevelsEvent {
  const RefreshProgress();
}

// States
abstract class LevelsState extends Equatable {
  const LevelsState();

  @override
  List<Object?> get props => [];
}

class LevelsInitial extends LevelsState {}

class LevelsLoading extends LevelsState {}

class ZonesLoaded extends LevelsState {
  final List<GameZone> zones;
  final int totalStars;

  const ZonesLoaded({required this.zones, required this.totalStars});

  @override
  List<Object?> get props => [zones, totalStars];
}

class LevelsLoaded extends LevelsState {
  final GameZone zone;
  final List<Level> levels;

  const LevelsLoaded({required this.zone, required this.levels});

  @override
  List<Object?> get props => [zone, levels];
}

class LevelsError extends LevelsState {
  final String message;
  const LevelsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class LevelsBloc extends Bloc<LevelsEvent, LevelsState> {
  final LevelsRepository repository;

  LevelsBloc({required this.repository}) : super(LevelsInitial()) {
    on<LoadZones>(_onLoadZones);
    on<LoadLevelsForZone>(_onLoadLevelsForZone);
    on<RefreshProgress>(_onRefreshProgress);
  }

  Future<void> _onLoadZones(LoadZones event, Emitter<LevelsState> emit) async {
    emit(LevelsLoading());
    try {
      final zones = await repository.getZones();
      final totalStars = await repository.getTotalStars();
      emit(ZonesLoaded(zones: zones, totalStars: totalStars));
    } catch (e) {
      emit(LevelsError(e.toString()));
    }
  }

  Future<void> _onLoadLevelsForZone(
      LoadLevelsForZone event, Emitter<LevelsState> emit) async {
    emit(LevelsLoading());
    try {
      final zones = await repository.getZones();
      final zone = zones.firstWhere((z) => z.id == event.zoneId);
      final levels = await repository.getLevelsForZone(event.zoneId);
      emit(LevelsLoaded(zone: zone, levels: levels));
    } catch (e) {
      emit(LevelsError(e.toString()));
    }
  }

  Future<void> _onRefreshProgress(
      RefreshProgress event, Emitter<LevelsState> emit) async {
    add(const LoadZones());
  }
}
