import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_summary.freezed.dart';

/// Agrupa um total de gastos por categoria num dado mês
@freezed
class CategoryTotal with _$CategoryTotal {
  const factory CategoryTotal({
    required String categoryName,
    required double total,
    required int count,
    @Default(0.0) double percentage,
    @Default('#000000') String color,
  }) = _CategoryTotal;
}

/// Resumo financeiro completo de um mês
@freezed
class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    required int month,
    required int year,
    required double totalExpenses,
    required double totalIncome,
    required List<CategoryTotal> byCategory,
  }) = _MonthlySummary;

  // Campos calculados
  const MonthlySummary._();

  double get balance => totalIncome - totalExpenses;
  bool get isPositive => balance >= 0;

  /// Percentual de cada categoria sobre o total de despesas
  double categoryPercent(String categoryName) {
    if (totalExpenses == 0) return 0;
    final cat = byCategory.where((c) => c.categoryName == categoryName);
    if (cat.isEmpty) return 0;
    return (cat.first.total / totalExpenses) * 100;
  }
}
