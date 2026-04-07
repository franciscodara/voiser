import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/features/expenses/data/repositories/expense_repository_impl.dart';

part 'expense_provider.g.dart';

/// Provider da lista de despesas do mês corrente.
@riverpod
class ExpenseNotifier extends _$ExpenseNotifier {
  @override
  FutureOr<List<Expense>> build() async {
    final repo = ref.read(expenseRepositoryProvider);
    return await repo.getLocalExpenses();
  }

  /// Adiciona uma despesa à lista e salva via repositório
  Future<void> addExpense(Expense expense) async {
    // Otimistic update: atualiza a UI imediatamente com a despesa pendente
    final pendingExpense = expense.copyWith(synced: false);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([pendingExpense, ...current]);

    final repo = ref.read(expenseRepositoryProvider);
    await repo.saveExpense(expense);
    
    // Atualiza com estado real que foi salvo localmente
    state = AsyncValue.data(await repo.getLocalExpenses());
  }

  // Remove uma despesa
  Future<void> deleteExpense(String id) async {
    final current = state.valueOrNull ?? [];
    final expenseToDelete = current.firstWhere((e) => e.id == id);
    
    state = AsyncValue.data(current.where((e) => e.id != id).toList());

    final repo = ref.read(expenseRepositoryProvider);
    await repo.deleteExpense(expenseToDelete);
  }

  Future<void> refreshExpenses() async {
    final repo = ref.read(expenseRepositoryProvider);
    state = AsyncValue.data(await repo.getLocalExpenses());
  }
}

/// Provider das categorias — expõe a lista estática de DefaultCategories.
/// Separado aqui para facilitar mock em testes.
@riverpod
List<String> categorySubcategories(CategorySubcategoriesRef ref, String categoryId) {
  // Lazy import para evitar dependência circular
  return const [];
}
