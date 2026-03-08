import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  @override
  Future<AppUser?> get currentUser async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  @override
  Future<AppUser> signInAnonymously() async {
    try {
      final result = await _firebaseAuth.signInAnonymously();
      final user = result.user;
      if (user == null) {
        throw const AuthException('Failed to sign in anonymously.');
      }

      // Generate a random username if this is the first time
      final box = Hive.box(AppConstants.hiveUserBox);
      if (box.get('username') == null) {
        final username = _generateRandomUsername();
        await box.put('username', username);
      }

      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Anonymous sign-in failed.');
    }
  }

  @override
  Future<void> updateUsername(String username) async {
    final box = Hive.box(AppConstants.hiveUserBox);
    await box.put('username', username);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  AppUser _mapFirebaseUser(User user) {
    final box = Hive.box(AppConstants.hiveUserBox);
    final username = box.get('username', defaultValue: 'Player') as String;
    final isGamesConnected =
        box.get('gamesServicesConnected', defaultValue: false) as bool;

    return AppUser(
      uid: user.uid,
      username: username,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      isGamesServicesConnected: isGamesConnected,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  static String _generateRandomUsername() {
    const adjectives = [
      'Swift', 'Bold', 'Lucky', 'Clever', 'Mighty',
      'Brave', 'Cosmic', 'Epic', 'Fierce', 'Grand',
      'Noble', 'Royal', 'Turbo', 'Ultra', 'Vivid',
      'Zen', 'Alpha', 'Blaze', 'Frost', 'Storm',
    ];
    const nouns = [
      'Merger', 'Slider', 'Stacker', 'Puzzler', 'Tiler',
      'Shifter', 'Mover', 'Builder', 'Crusher', 'Dasher',
      'Racer', 'Chaser', 'Hunter', 'Seeker', 'Master',
      'Wizard', 'Knight', 'Ninja', 'Pilot', 'Scout',
    ];
    final rng = Random();
    final adj = adjectives[rng.nextInt(adjectives.length)];
    final noun = nouns[rng.nextInt(nouns.length)];
    final number = rng.nextInt(900) + 100; // 100-999
    return '$adj$noun$number';
  }
}
