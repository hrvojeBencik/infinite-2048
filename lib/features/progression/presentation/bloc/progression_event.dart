part of 'progression_bloc.dart';

sealed class ProgressionEvent extends Equatable {
  const ProgressionEvent();

  @override
  List<Object?> get props => [];
}

class LoadProgression extends ProgressionEvent {
  const LoadProgression();
}

class UpdateTileTheme extends ProgressionEvent {
  final String themeId;

  const UpdateTileTheme(this.themeId);

  @override
  List<Object?> get props => [themeId];
}
