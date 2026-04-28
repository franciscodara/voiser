import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/core/providers/sync_status_provider.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/auth/data/datasources/google_sheets_setup_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/local/expense_hive_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/remote/google_sheets_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'sync_queue_service.g.dart';

@Riverpod(keepAlive: true)
SyncQueueService syncQueueService(SyncQueueServiceRef ref) {
  return SyncQueueService(ref);
}

class SyncQueueService {
  final SyncQueueServiceRef _ref;
  bool _isSyncing = false;
  final _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/spreadsheets',
  ]);

  SyncQueueService(this._ref);

  void startConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        debugPrint('📶 Conectividade restaurada — disparando sync...');
        processQueue();
      }
    });
  }

  /// Obtém um accessToken sempre fresco via GoogleSignIn.
  /// Evita erros 401 por token expirado (tokens OAuth duram ~1h).
  Future<String?> _getFreshAccessToken() async {
    try {
      // Tenta renovar silenciosamente sem abrir a tela de login
      final account = await _googleSignIn.signInSilently();
      if (account == null) {
        // Fallback: usa o token do provider (pode estar expirado)
        final user = await _ref.read(authNotifierProvider.future);
        debugPrint('⚠️ SilentSignIn falhou — usando token do cache.');
        return user?.accessToken;
      }
      final auth = await account.authentication;
      final token = auth.accessToken;
      if (token != null) {
        debugPrint('🔑 Token renovado com sucesso: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Erro ao renovar token: $e');
      // Último recurso: token do provider
      final user = await _ref.read(authNotifierProvider.future);
      return user?.accessToken;
    }
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    // ── Notifica a UI que o sync iniciou (Opção A) ─────────────────────────
    _ref.read(syncStatusNotifierProvider.notifier).setSyncing();

    bool hadError = false;

    try {
      final localDatasource = _ref.read(expenseHiveDatasourceProvider);
      final pendingExpenses = await localDatasource.getPendingExpenses();

      if (pendingExpenses.isEmpty) {
        debugPrint('📭 Fila de sync vazia — nada a fazer.');
        _ref.read(syncStatusNotifierProvider.notifier).setIdle();
        return;
      }

      debugPrint('📋 ${pendingExpenses.length} despesa(s) pendente(s) na fila.');

      // Obtém token fresco para evitar erros 401
      final accessToken = await _getFreshAccessToken();
      if (accessToken == null) {
        debugPrint('🔐 Usuário não autenticado — sync abortado.');
        _ref.read(syncStatusNotifierProvider.notifier).setIdle();
        return;
      }

      final sheetsSetup = await _ref.read(googleSheetsSetupDatasourceProvider.future);
      final spreadsheetId = sheetsSetup.getStoredSpreadsheetId();
      if (spreadsheetId == null || spreadsheetId.isEmpty) {
        debugPrint('📄 SpreadsheetId não encontrado — sync abortado.');
        _ref.read(syncStatusNotifierProvider.notifier).setIdle();
        return;
      }

      debugPrint('📊 Planilha alvo: $spreadsheetId');
      final remoteDatasource = _ref.read(googleSheetsDatasourceProvider);

      for (var expense in pendingExpenses) {
        try {
          if (expense.deleted) {
            debugPrint('🗑️ Removendo despesa ${expense.id} remotamente...');
            await remoteDatasource.deleteExpense(expense.id, spreadsheetId, accessToken);
            await localDatasource.deleteExpense(expense.id);
            debugPrint('✅ Despesa deletada: ${expense.id}');
          } else {
            debugPrint('⏳ Sincronizando: ${expense.id} | R\$${expense.amount} | ${expense.categoryName}');
            debugPrint('   Payload: data=${expense.date} | tipo=${expense.type.name} | origem=${expense.origin.name}');
            await remoteDatasource.appendExpense(expense, spreadsheetId, accessToken);
            await localDatasource.markAsSynced(expense.id);
            debugPrint('✅ Sincronizado com Sheets: ${expense.id}');
          }
        } catch (e, st) {
          hadError = true;
          debugPrint('❌ Falha ao sincronizar ${expense.id}: ${e.runtimeType} — $e');
          debugPrintStack(stackTrace: st, maxFrames: 5);
          // Continua para a próxima despesa (não aborta toda a fila)
        }
      }
    } catch (e) {
      hadError = true;
      debugPrint('❌ Erro geral no processQueue: $e');
    } finally {
      _isSyncing = false;
      // ── Notifica resultado final ──────────────────────────────────────────
      if (hadError) {
        _ref.read(syncStatusNotifierProvider.notifier).setError();
      } else {
        _ref.read(syncStatusNotifierProvider.notifier).setSuccess();
      }
    }
  }
}
