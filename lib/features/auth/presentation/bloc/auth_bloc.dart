import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../leaderboard/data/datasources/leaderboard_remote_datasource.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthUpdateUsername extends AuthEvent {
  final String username;
  const AuthUpdateUsername(this.username);
  @override
  List<Object?> get props => [username];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class _AuthUserChanged extends AuthEvent {
  final AppUser? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository? repository;
  final LeaderboardRemoteDataSource? leaderboardDataSource;
  StreamSubscription<AppUser?>? _authSub;

  AuthBloc({this.repository, this.leaderboardDataSource}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthUpdateUsername>(_onUpdateUsername);
    on<AuthSignOutRequested>(_onSignOut);
    on<_AuthUserChanged>(_onUserChanged);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    if (repository == null) {
      emit(AuthUnauthenticated());
      return;
    }

    // Check if already signed in
    final currentUser = await repository!.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      // Auto sign-in anonymously
      try {
        final user = await repository!.signInAnonymously();
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(AuthUnauthenticated());
      }
    }

    // Listen for future auth state changes
    _authSub?.cancel();
    _authSub = repository!.authStateChanges.listen(
      (user) => add(_AuthUserChanged(user)),
    );
  }

  Future<void> _onUpdateUsername(
      AuthUpdateUsername event, Emitter<AuthState> emit) async {
    if (repository == null) return;
    await repository!.updateUsername(event.username);

    // Update leaderboard entries with new username
    final currentUser = await repository!.currentUser;
    if (currentUser != null) {
      leaderboardDataSource?.updateDisplayName(
        uid: currentUser.uid,
        displayName: event.username,
      );
      emit(AuthAuthenticated(currentUser));
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await repository?.signOut();
    emit(AuthUnauthenticated());
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
