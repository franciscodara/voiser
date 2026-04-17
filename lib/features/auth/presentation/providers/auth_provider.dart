import 'package:finwise/features/auth/data/datasources/google_sheets_setup_datasource.dart';
import 'package:finwise/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:finwise/features/auth/domain/entities/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.getStoredUser();
  }

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signIn();

      if (user != null) {
        // After successful login, set up Google Sheets (idempotent — skips if already created)
        final sheetsSetup = await ref.read(googleSheetsSetupDatasourceProvider.future);
        final authHeaders = {'Authorization': 'Bearer ${user.accessToken}'};

        final spreadsheetId = await sheetsSetup.setupFinWiseSpreadsheet(authHeaders);

        // Log the spreadsheet link so the user can verify it in Drive
        // ignore: avoid_print
        print('✅ FinWise Spreadsheet ready: https://docs.google.com/spreadsheets/d/$spreadsheetId');
      }

      state = AsyncValue.data(user);
    } catch (e, st) {
      if (e.toString().contains('401')) {
        print('🔄 Token expirado, tentando refresh silencioso...');
        try {
          final repo = ref.read(authRepositoryProvider);
          // O signInSilently() faz silent refresh implicitamente se possível
          final refreshedUser = await repo.signInSilently();
          if (refreshedUser != null) {
            state = AsyncValue.data(refreshedUser);
            return;
          }
        } catch (_) {}
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
