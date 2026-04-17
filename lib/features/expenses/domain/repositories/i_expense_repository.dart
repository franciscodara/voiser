import '../entities/expense.dart';

abstract class IExpenseRepository {
  Future<void> saveExpense(Expense expense);
  Future<List<Expense>> getLocalExpenses();
  Future<void> deleteExpense(Expense expense);
}
