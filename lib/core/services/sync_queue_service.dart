import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/auth/data/datasources/google_sheets_setup_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/local/expense_hive_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/remote/google_sheets_datasource.dart';

part 'sync_queue_service.g.dart';

@Riverpod(keepAlive: true)
SyncQueueService syncQueueService(SyncQueueServiceRef ref) {
  return SyncQueueService(ref);
}

class SyncQueueService {
  final SyncQueueServiceRef _ref;
  bool _isSyncing = false;

  SyncQueueService(this._ref);

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final localDatasource = _ref.read(expenseHiveDatasourceProvider);
      final pendingExpenses = await localDatasource.getPendingExpenses();

      if (pendingExpenses.isEmpty) {
        _isSyncing = false;
        return;
      }

      final user = await _ref.read(authNotifierProvider.future);
      if (user == null) {
        _isSyncing = false;
        return;
      }

      final sheetsSetup = _ref.read(googleSheetsSetupDatasourceProvider);
      final spreadsheetId = await sheetsSetup.getStoredSpreadsheetId();
      if (spreadsheetId == null) {
        _isSyncing = false;
        return;
      }

      final remoteDatasource = _ref.read(googleSheetsDatasourceProvider);

      for (var expense in pendingExpenses) {
        try {
          print('⏳ Sincronizando despesa ${expense.id}...');
          await remoteDatasource.appendExpense(expense, spreadsheetId, user.accessToken);
          await localDatasource.markAsSynced(expense.id);
          print('✅ Despesa sincronizada com o Google Sheets: ${expense.id}');
        } catch (e, st) {
          print('❌ Falha ao sincronizar despesa ${expense.id}: $e');
          print(st);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
