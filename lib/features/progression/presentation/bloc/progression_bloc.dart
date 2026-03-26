import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/progression_local_datasource.dart';
import '../../domain/entities/player_profile.dart';
import '../../domain/entities/tile_theme.dart';

part 'progression_event.dart';
part 'progression_state.dart';

class ProgressionBloc extends Bloc<ProgressionEvent, ProgressionState> {
  final ProgressionLocalDataSource _dataSource;

  ProgressionBloc({required ProgressionLocalDataSource dataSource})
      : _dataSource = dataSource,
        super(const ProgressionInitial()) {
    on<LoadProgression>(_onLoad);
    on<UpdateTileTheme>(_onUpdateTheme);
  }

  Future<void> _onLoad(
    LoadProgression event,
    Emitter<ProgressionState> emit,
  ) async {
    final profile = _dataSource.getProfile();
    final theme = TileThemes.getById(profile.activeTileThemeId);
    emit(ProgressionLoaded(profile: profile, activeTileTheme: theme));
  }

  Future<void> _onUpdateTheme(
    UpdateTileTheme event,
    Emitter<ProgressionState> emit,
  ) async {
    await _dataSource.setActiveTileTheme(event.themeId);
    final profile = _dataSource.getProfile();
    final theme = TileThemes.getById(profile.activeTileThemeId);
    emit(ProgressionLoaded(profile: profile, activeTileTheme: theme));
  }
}
