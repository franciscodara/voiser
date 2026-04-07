import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'sign_in_with_google.g.dart';

@riverpod
SignInWithGoogle signInWithGoogle(SignInWithGoogleRef ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignInWithGoogle(repo);
}

class SignInWithGoogle {
  final IAuthRepository _repository;

  SignInWithGoogle(this._repository);

  Future<User?> call() async {
    return await _repository.signIn();
  }
}
