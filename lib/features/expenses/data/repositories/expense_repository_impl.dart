import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/auth/data/datasources/google_sheets_setup_datasource.dart';
import '../../domain/entities/expense.dart';
import '../datasources/local/expense_hive_datasource.dart';
import '../datasources/remote/google_sheets_datasource.dart';
import 'package:finwise/core/services/sync_queue_service.dart';

part 'expense_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(ExpenseRepositoryRef ref) {
  return ExpenseRepository(
    ref.read(expenseHiveDatasourceProvider),
    ref.read(googleSheetsDatasourceProvider),
    ref,
  );
}

class ExpenseRepository {
  final ExpenseHiveDatasource _localDatasource;
  final GoogleSheetsDatasource _remoteDatasource;
  final ExpenseRepositoryRef _ref;

  ExpenseRepository(this._localDatasource, this._remoteDatasource, this._ref);

  Future<void> saveExpense(Expense expense) async {
    final pendingExpense = expense.copyWith(synced: false);
    await _localDatasource.saveExpense(pendingExpense);
    
    // Dispara a fila de sync em background silenciosamente
    _ref.read(syncQueueServiceProvider).processQueue();
  }

  Future<List<Expense>> getLocalExpenses() async {
    return await _localDatasource.getAllExpenses();
  }

  Future<void> deleteExpense(Expense expense) async {
    await _localDatasource.deleteExpense(expense.id);
    
    try {
      final user = await _ref.read(authNotifierProvider.future);
      if (user != null) {
        final sheetsSetup = _ref.read(googleSheetsSetupDatasourceProvider);
        final spreadsheetId = await sheetsSetup.getStoredSpreadsheetId();
        if (spreadsheetId != null) {
          await _remoteDatasource.deleteExpense(expense.id, spreadsheetId, user.accessToken);
        }
      }
    } catch (_) {}
  }
}
