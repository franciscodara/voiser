import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> signIn();
  Future<void> signOut();
  Future<User?> getStoredUser();
}
