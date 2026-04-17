import 'package:flutter/foundation.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:finwise/core/network/google_auth_client.dart';
import '../../../domain/entities/expense.dart';

part 'google_sheets_datasource.g.dart';

@Riverpod(keepAlive: true)
GoogleSheetsDatasource googleSheetsDatasource(GoogleSheetsDatasourceRef ref) {
  return GoogleSheetsDatasource();
}

class GoogleSheetsDatasource {
  Future<void> appendExpense(Expense expense, String spreadsheetId, String accessToken) async {
    final client = GoogleAuthClient({'Authorization': 'Bearer $accessToken'});
    final sheetsApi = sheets.SheetsApi(client);

    // Idempotência: Checa se a despesa já foi enviada no Google Sheets para evitar duplicação em redes fracas
    try {
      final getResponse = await sheetsApi.spreadsheets.values.get(spreadsheetId, 'Transações!A:I');
      final rows = getResponse.values;
      if (rows != null) {
        for (int i = 1; i < rows.length; i++) {
          if (rows[i].length > 8 && rows[i][8].toString() == expense.id) {
            debugPrint('⚠️ Idempotência: despesa ${expense.id} já existe na planilha — ignorando.');
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Falha ao checar idempotência (continuando): $e');
    }

    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    final valueRange = sheets.ValueRange(
      values: [
        [
          dateFormatter.format(expense.date),
          timeFormatter.format(expense.date),
          expense.categoryName,
          expense.subcategory ?? '',
          expense.description ?? '',
          expense.amount,
          expense.type.name,
          expense.origin.name,
          expense.id, // Coluna I para identificação
        ]
      ],
    );

    debugPrint('🌐 Enviando para Transações!A:I — ID: ${expense.id}');
    try {
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        'Transações!A:I',
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );
      debugPrint('🟢 Append concluído com sucesso para: ${expense.id}');
    } on sheets.DetailedApiRequestError catch (e) {
      debugPrint('❌ Erro HTTP ${e.status} da API Sheets: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Erro inesperado no append: ${e.runtimeType} — $e');
      rethrow;
    }
  }

  Future<List<Expense>> getExpenses(String spreadsheetId, String accessToken, {int? month, int? year}) async {
    final client = GoogleAuthClient({'Authorization': 'Bearer $accessToken'});
    final sheetsApi = sheets.SheetsApi(client);

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      'Transações!A:I',
    );

    final rows = response.values;
    if (rows == null || rows.isEmpty || rows.length == 1) return [];

    final List<Expense> expenses = [];
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      try {
        final dateStr = row[0].toString();
        final timeStr = row.length > 1 ? row[1].toString() : '00:00';
        final dateTime = dateFormatter.parse('$dateStr $timeStr');

        if (month != null && dateTime.month != month) continue;
        if (year != null && dateTime.year != year) continue;

        expenses.add(Expense(
          id: row.length > 8 ? row[8].toString() : DateTime.now().toIso8601String(),
          date: dateTime,
          categoryId: '', 
          categoryName: row.length > 2 ? row[2].toString() : '—',
          subcategory: row.length > 3 ? row[3].toString() : null,
          description: row.length > 4 ? row[4].toString() : null,
          amount: row.length > 5 ? double.tryParse(row[5].toString().replaceAll(',', '.')) ?? 0.0 : 0.0,
          type: row.length > 6 && row[6].toString() == 'income' ? TransactionType.income : TransactionType.expense,
          origin: row.length > 7 && row[7].toString() == 'voice' ? EntryOrigin.voice : EntryOrigin.manual,
          synced: true,
        ));
      } catch (e) {
        // Ignorar linha inválida
      }
    }
    return expenses;
  }

  Future<void> deleteExpense(String id, String spreadsheetId, String accessToken) async {
    final client = GoogleAuthClient({'Authorization': 'Bearer $accessToken'});
    final sheetsApi = sheets.SheetsApi(client);

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      'Transações!A:I',
    );

    final rows = response.values;
    if (rows == null || rows.length <= 1) return;

    int rowIndexToDelete = -1;
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length > 8 && row[8].toString() == id) {
        rowIndexToDelete = i;
        break;
      }
    }

    if (rowIndexToDelete == -1) return; 

    final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
    final sheet = spreadsheet.sheets?.firstWhere((s) => s.properties?.title == 'Transações');
    final sheetId = sheet?.properties?.sheetId;

    if (sheetId == null) return;

    final deleteRequest = sheets.Request(
      deleteDimension: sheets.DeleteDimensionRequest(
        range: sheets.DimensionRange(
          sheetId: sheetId,
          dimension: 'ROWS',
          startIndex: rowIndexToDelete,
          endIndex: rowIndexToDelete + 1,
        ),
      ),
    );

    await sheetsApi.spreadsheets.batchUpdate(
      sheets.BatchUpdateSpreadsheetRequest(requests: [deleteRequest]),
      spreadsheetId,
    );
  }
}
