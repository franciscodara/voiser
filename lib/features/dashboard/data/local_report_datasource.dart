import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:finwise/features/dashboard/domain/monthly_summary.dart';
import 'package:finwise/core/constants/default_categories.dart';

part 'local_report_datasource.g.dart';

@riverpod
LocalReportDatasource localReportDatasource(LocalReportDatasourceRef ref) {
  return LocalReportDatasource(ref);
}

class LocalReportDatasource {
  final LocalReportDatasourceRef _ref;

  LocalReportDatasource(this._ref);

  Future<MonthlySummary> getMonthlySummary({
    required int month,
    required int year,
  }) async {
    final repository = _ref.read(expenseRepositoryProvider);
    final allExpenses = await repository.getLocalExpenses();

    double totalExpenses = 0.0;
    double totalIncome = 0.0;
    final Map<String, double> categoryMap = {};
    final Map<String, int> categoryCount = {};
    final Map<String, String> categoryColors = {};

    for (var expense in allExpenses) {
      if (expense.date.month == month && expense.date.year == year) {
        if (expense.type.name == 'income') {
          totalIncome += expense.amount;
        } else {
          totalExpenses += expense.amount;
          final catName = expense.categoryName;
          categoryMap[catName] = (categoryMap[catName] ?? 0.0) + expense.amount;
          categoryCount[catName] = (categoryCount[catName] ?? 0) + 1;
        }
      }
    }

    final byCategory = categoryMap.entries
        .map((e) {
          final catColor = DefaultCategories.findByName(e.key)?.color.value.toRadixString(16).padLeft(8, '0') ?? 'FF94A3B8';
          final hexColor = '#${catColor.substring(2)}';
          
          return CategoryTotal(
            categoryName: e.key,
            total: e.value,
            count: categoryCount[e.key] ?? 0,
            percentage: totalExpenses > 0 ? (e.value / totalExpenses) * 100 : 0.0,
            color: hexColor,
          );
        })
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return MonthlySummary(
      month: month,
      year: year,
      totalExpenses: totalExpenses,
      totalIncome: totalIncome,
      byCategory: byCategory,
    );
  }
}
