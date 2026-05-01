import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/expense.dart';

part 'expense_hive_datasource.g.dart';

@Riverpod(keepAlive: true)
ExpenseHiveDatasource expenseHiveDatasource(ExpenseHiveDatasourceRef ref) {
  return ExpenseHiveDatasource();
}

class ExpenseHiveDatasource {
  static const _boxName = 'expenses_box';

  Future<Box<String>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<String>(_boxName);
    }
    return Hive.box<String>(_boxName);
  }

  Future<void> saveExpense(Expense expense) async {
    final box = await _getBox();
    await box.put(expense.id, jsonEncode(expense.toJson()));
  }

  Future<void> markAsSynced(String id) async {
    final box = await _getBox();
    final data = box.get(id);
    if (data != null) {
      try {
        final expense = Expense.fromJson(jsonDecode(data) as Map<String, dynamic>);
        final updatedExpense = expense.copyWith(synced: true);
        await box.put(id, jsonEncode(updatedExpense.toJson()));
      } catch (e) {
        // Ignorar
      }
    }
  }

  Future<List<Expense>> getPendingExpenses() async {
    final box = await _getBox();
    final List<Expense> pending = [];
    
    for (final data in box.values) {
      try {
        final expense = Expense.fromJson(jsonDecode(data) as Map<String, dynamic>);
        if (!expense.synced) {
          pending.add(expense);
        }
      } catch (e) {
        // Ignorar
      }
    }
    // Ordenar do mais novo pro mais antigo
    pending.sort((a, b) => b.date.compareTo(a.date));
    return pending;
  }

  Future<List<Expense>> getAllExpenses() async {
    final box = await _getBox();
    final List<Expense> all = [];
    
    for (final data in box.values) {
      try {
        all.add(Expense.fromJson(jsonDecode(data) as Map<String, dynamic>));
      } catch (e) {
        // Ignorar
      }
    }
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }
  
  Future<void> deleteExpense(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> clearUserData() async {
    final box = await _getBox();
    await box.clear();
  }
}
