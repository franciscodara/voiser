import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/google_auth_client.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'google_sheets_setup_datasource.g.dart';

@riverpod
Future<GoogleSheetsSetupDatasource> googleSheetsSetupDatasource(GoogleSheetsSetupDatasourceRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Migração do armazenamento antigo (FlutterSecureStorage) para o novo (SharedPreferences)
  const key = 'finwise_spreadsheet_id';
  if (prefs.getString(key) == null) {
    const secureStorage = FlutterSecureStorage();
    try {
      final oldId = await secureStorage.read(key: key);
      if (oldId != null && oldId.isNotEmpty) {
        await prefs.setString(key, oldId);
      }
    } catch (_) {
      // Ignorar erros caso não seja possível ler chave antiga
    }
  }

  return GoogleSheetsSetupDatasource(prefs);
}

class GoogleSheetsSetupDatasource {
  static const _spreadsheetIdKey = 'finwise_spreadsheet_id';
  final SharedPreferences _prefs;

  GoogleSheetsSetupDatasource(this._prefs);

  String? getStoredSpreadsheetId() {
    return _prefs.getString(_spreadsheetIdKey);
  }

  Future<String> setupFinWiseSpreadsheet(Map<String, String> authHeaders) async {
    // 1. Check if already exists
    final existingId = getStoredSpreadsheetId();
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('Sem conexão com a internet. Não foi possível configurar a planilha do Google Sheets.');
    }

    // 2. Setup auth client
    final client = GoogleAuthClient(authHeaders);
    final sheetsApi = sheets.SheetsApi(client);

    final currentYear = DateTime.now().year;

    // 3. Define the spreadsheet structure
    final spreadsheet = sheets.Spreadsheet(
      properties: sheets.SpreadsheetProperties(
        title: 'FinWise — Meu Orçamento $currentYear',
      ),
      sheets: [
        sheets.Sheet(
          properties: sheets.SheetProperties(title: 'Transações'),
        ),
        sheets.Sheet(
          properties: sheets.SheetProperties(title: 'Entradas'),
        ),
        sheets.Sheet(
          properties: sheets.SheetProperties(title: 'Categorias'),
        ),
        sheets.Sheet(
          properties: sheets.SheetProperties(title: 'Dashboard'),
        ),
      ],
    );

    // 4. Create the Spreadsheet on Google Drive
    final createdSpreadsheet = await sheetsApi.spreadsheets.create(spreadsheet);
    final spreadsheetId = createdSpreadsheet.spreadsheetId;

    if (spreadsheetId == null) {
      throw Exception('Failed to create spreadsheet (ID is null).');
    }

    // 5. Format headers for each tab
    await _updateHeaders(sheetsApi, spreadsheetId);

    // 6. Save locally
    await _prefs.setString(_spreadsheetIdKey, spreadsheetId);

    return spreadsheetId;
  }

  Future<void> _updateHeaders(sheets.SheetsApi api, String spreadsheetId) async {
    final batchUpdateRequest = sheets.BatchUpdateValuesRequest(
      valueInputOption: 'USER_ENTERED',
      data: [
        sheets.ValueRange(
          range: 'Transações!A1:I1',
          values: [
            ['Data', 'Hora', 'Categoria', 'Sub-categoria', 'Descrição', 'Valor', 'Tipo', 'Origem', 'ID']
          ],
        ),
        sheets.ValueRange(
          range: 'Categorias!A1:F1',
          values: [
            ['ID', 'Nome', 'Tipo', 'Cor', 'Ícone', 'Sub-categorias']
          ],
        ),
        sheets.ValueRange(
          range: 'Entradas!A1:D1',
          values: [
            ['Data', 'Fonte', 'Descrição', 'Valor']
          ],
        ),
        sheets.ValueRange(
          range: 'Dashboard!A1:C1',
          values: [
            ['Resumo', 'Valor', 'Detalhes']
          ],
        ),
      ],
    );

    await api.spreadsheets.values.batchUpdate(batchUpdateRequest, spreadsheetId);
  }
}
