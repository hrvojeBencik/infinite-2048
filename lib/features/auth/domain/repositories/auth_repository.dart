import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser?> get currentUser;
  Future<AppUser> signInAnonymously();
  Future<void> updateUsername(String username);
  Future<void> signOut();
}
