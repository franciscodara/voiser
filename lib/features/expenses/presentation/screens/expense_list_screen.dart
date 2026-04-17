import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finwise/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finwise/features/expenses/presentation/widgets/expense_card.dart';
import 'package:finwise/features/expenses/presentation/widgets/expense_group_header.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transações', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('Nenhuma despesa ainda.'));
          }
          
          final grouped = _groupByDate(expenses);
          final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(expenseNotifierProvider.notifier).refreshExpenses();
            },
            child: ListView.builder(
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final date = sortedKeys[index];
                final dayExpenses = grouped[date]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpenseGroupHeader(date: date),
                    ...dayExpenses.map((exp) => ExpenseCard(
                      expense: exp,
                      onDelete: () {
                        ref.read(expenseNotifierProvider.notifier).deleteExpense(exp.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Despesa apagada.')),
                        );
                      },
                    )),
                  ],
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Map<DateTime, List<Expense>> _groupByDate(List<Expense> expenses) {
    final map = <DateTime, List<Expense>>{};
    for (var exp in expenses) {
      final key = DateTime(exp.date.year, exp.date.month, exp.date.day);
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(exp);
    }
    return map;
  }
}

extension on AsyncValue<List<Expense>> {
  Widget quando({
    required Widget Function(List<Expense> data) data,
    required Widget Function() loading,
    required Widget Function(Object error, StackTrace stackTrace) error,
  }) {
    return when(data: data, loading: loading, error: error);
  }
}
