import 'package:flutter/foundation.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/core/network/google_auth_client.dart';
import 'package:finwise/core/constants/default_categories.dart';
import '../domain/monthly_summary.dart';

part 'sheets_report_datasource.g.dart';

@Riverpod(keepAlive: true)
SheetsReportDatasource sheetsReportDatasource(SheetsReportDatasourceRef ref) {
  return SheetsReportDatasource();
}

class SheetsReportDatasource {
  /// Lê a aba "Transações" e calcula o resumo para o mês/ano solicitados.
  /// Retorna null se não houver dados ou se o acesso falhar.
  Future<MonthlySummary?> getMonthlySummary({
    required String spreadsheetId,
    required String accessToken,
    required int month,
    required int year,
  }) async {
    debugPrint('📊 Dashboard: buscando dados $month/$year...');

    final client = GoogleAuthClient({'Authorization': 'Bearer $accessToken'});
    final sheetsApi = sheets.SheetsApi(client);

    late final sheets.ValueRange response;
    try {
      response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Transações!A:I',
      );
    } on sheets.DetailedApiRequestError catch (e) {
      debugPrint('❌ Erro HTTP ${e.status} ao buscar dados do dashboard: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados do dashboard: $e');
      rethrow;
    }

    final rows = response.values;
    if (rows == null || rows.length <= 1) {
      debugPrint('📊 Dashboard: planilha vazia ou só com header.');
      return MonthlySummary(
        month: month,
        year: year,
        totalExpenses: 0,
        totalIncome: 0,
        byCategory: [],
      );
    }

    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    double totalExpenses = 0;
    double totalIncome = 0;
    final Map<String, double> categoryMap = {};
    final Map<String, int> categoryCount = {};

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      try {
        final dateStr = row[0].toString();
        final timeStr = row.length > 1 ? row[1].toString() : '00:00';
        final dateTime = dateFormatter.parse('$dateStr $timeStr');

        if (dateTime.month != month || dateTime.year != year) continue;

        final categoryName = row.length > 2 ? row[2].toString() : 'Outros';
        final amountStr = row[5].toString().replaceAll(',', '.');
        final amount = double.tryParse(amountStr) ?? 0.0;
        final type = row.length > 6 ? row[6].toString() : 'expense';

        if (type == 'income') {
          totalIncome += amount;
        } else {
          totalExpenses += amount;
          categoryMap[categoryName] = (categoryMap[categoryName] ?? 0) + amount;
          categoryCount[categoryName] = (categoryCount[categoryName] ?? 0) + 1;
        }
      } catch (e) {
        continue; // linha inválida, ignora
      }
    }

    // Ordena categorias do maior para o menor gasto
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

    debugPrint(
      '📊 Dashboard: despesas=R\$${totalExpenses.toStringAsFixed(2)} | '
      'receitas=R\$${totalIncome.toStringAsFixed(2)} | '
      '${byCategory.length} categorias',
    );

    return MonthlySummary(
      month: month,
      year: year,
      totalExpenses: totalExpenses,
      totalIncome: totalIncome,
      byCategory: byCategory,
    );
  }
}
