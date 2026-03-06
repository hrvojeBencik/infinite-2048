import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to access local cache.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure([super.message = 'Subscription operation failed.']);
}

class GameFailure extends Failure {
  const GameFailure([super.message = 'An error occurred during the game.']);
}
