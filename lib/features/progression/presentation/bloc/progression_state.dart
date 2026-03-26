part of 'progression_bloc.dart';

sealed class ProgressionState extends Equatable {
  const ProgressionState();

  @override
  List<Object?> get props => [];
}

class ProgressionInitial extends ProgressionState {
  const ProgressionInitial();
}

class ProgressionLoaded extends ProgressionState {
  final PlayerProfile profile;
  final TileTheme activeTileTheme;

  const ProgressionLoaded({
    required this.profile,
    required this.activeTileTheme,
  });

  @override
  List<Object?> get props => [profile, activeTileTheme];
}
