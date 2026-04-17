import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/auth/data/datasources/google_sheets_setup_datasource.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../datasources/local/expense_hive_datasource.dart';
import '../datasources/remote/google_sheets_datasource.dart';
import 'package:finwise/core/services/sync_queue_service.dart';

part 'expense_repository_impl.g.dart';

@Riverpod(keepAlive: true)
IExpenseRepository expenseRepository(ExpenseRepositoryRef ref) {
  return ExpenseRepositoryImpl(
    ref.read(expenseHiveDatasourceProvider),
    ref.read(googleSheetsDatasourceProvider),
    ref,
  );
}

class ExpenseRepositoryImpl implements IExpenseRepository {
  final ExpenseHiveDatasource _localDatasource;
  final GoogleSheetsDatasource _remoteDatasource;
  final ExpenseRepositoryRef _ref;

  ExpenseRepositoryImpl(this._localDatasource, this._remoteDatasource, this._ref);

  @override
  Future<void> saveExpense(Expense expense) async {
    final pendingExpense = expense.copyWith(synced: false);
    await _localDatasource.saveExpense(pendingExpense);
    
    // Dispara a fila de sync em background silenciosamente
    _ref.read(syncQueueServiceProvider).processQueue();
  }

  @override
  Future<List<Expense>> getLocalExpenses() async {
    final all = await _localDatasource.getAllExpenses();
    return all.where((e) => !e.deleted).toList();
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    // Soft Delete: Marca como deletado, tira o sync flag e salva.
    final deletedExpense = expense.copyWith(deleted: true, synced: false);
    await _localDatasource.saveExpense(deletedExpense);
    
    // Dispara a queue que irá cuidar do hard-delete remotamente e depois limpar o Hive
    _ref.read(syncQueueServiceProvider).processQueue();
  }
}
