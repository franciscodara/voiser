import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/google_auth_datasource.dart';
import '../models/user_model.dart';

part 'auth_repository_impl.g.dart';

@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  final dataSource = ref.watch(googleAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
}

class AuthRepositoryImpl implements IAuthRepository {
  final GoogleAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User?> signIn() async {
    final model = await _dataSource.signIn();
    return model?.toDomain();
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<User?> getStoredUser() async {
    final model = await _dataSource.getStoredUser();
    return model?.toDomain();
  }
}
