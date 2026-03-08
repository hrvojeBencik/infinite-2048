part of 'endless_bloc.dart';

abstract class EndlessEvent extends Equatable {
  const EndlessEvent();

  @override
  List<Object?> get props => [];
}

class StartEndless extends EndlessEvent {
  final int undosAvailable;
  const StartEndless({this.undosAvailable = 3});

  @override
  List<Object?> get props => [undosAvailable];
}

class EndlessSwipe extends EndlessEvent {
  final MoveDirection direction;
  const EndlessSwipe(this.direction);

  @override
  List<Object?> get props => [direction];
}

class EndlessUndo extends EndlessEvent {
  const EndlessUndo();
}

class EndlessPause extends EndlessEvent {
  const EndlessPause();
}

class EndlessResume extends EndlessEvent {
  const EndlessResume();
}

class EndlessSaveAndExit extends EndlessEvent {
  const EndlessSaveAndExit();
}

class EndlessRestart extends EndlessEvent {
  final int undosAvailable;
  const EndlessRestart({this.undosAvailable = 3});

  @override
  List<Object?> get props => [undosAvailable];
}
