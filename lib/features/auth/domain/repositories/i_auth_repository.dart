import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> signIn();
  Future<User?> signInSilently();
  Future<void> signOut();
  Future<User?> getStoredUser();
}
