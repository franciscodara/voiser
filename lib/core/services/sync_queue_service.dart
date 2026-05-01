import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/core/providers/sync_status_provider.dart';
import 'package:finwise/features/expenses/data/datasources/local/expense_hive_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/remote/supabase_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finwise/core/services/sync_pull_service.dart';

part 'sync_queue_service.g.dart';

@Riverpod(keepAlive: true)
SyncQueueService syncQueueService(SyncQueueServiceRef ref) {
  return SyncQueueService(ref);
}

class SyncQueueService {
  final SyncQueueServiceRef _ref;
  bool _isSyncing = false;

  SyncQueueService(this._ref);

  void startConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        debugPrint('📶 Conectividade restaurada — disparando sync...');
        processQueue();
      }
    });
  }

  Future<void> processQueue() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('🔐 [SyncQueue] Sessão ausente. Sincronização abortada.');
      return;
    }

    if (_isSyncing) return;
    _isSyncing = true;

    // Notifica a UI que o sync iniciou
    _ref.read(syncStatusNotifierProvider.notifier).setSyncing();

    bool hadError = false;

    try {
      final localDatasource = _ref.read(expenseHiveDatasourceProvider);
      final pendingExpenses = await localDatasource.getPendingExpenses();

      if (pendingExpenses.isNotEmpty) {
        debugPrint('📋 ${pendingExpenses.length} despesa(s) pendente(s) na fila (PUSH).');

        final remoteDatasource = _ref.read(supabaseDatasourceProvider);

        for (var expense in pendingExpenses) {
          try {
            debugPrint('⏳ [SyncQueue] Sincronizando: ${expense.id} | Deletado: ${expense.deleted}');
            
            // 1. O Upsert resolve tanto inserção, edição, quanto soft-delete (mandando deleted_at).
            await remoteDatasource.upsertExpense(expense);
            
            // 2. Resolve o estado local (Hive)
            if (expense.deleted || expense.deletedAt != null) {
              // Se estava marcado para deletar offline, agora que subiu o "deleted_at", limpamos do Hive.
              await localDatasource.deleteExpense(expense.id);
              debugPrint('✅ [SyncQueue] Soft delete submetido ao Supabase e removido fisicamente do Hive: ${expense.id}');
            } else {
              // Se era inserção/update, marca como sincronizado localmente.
              await localDatasource.markAsSynced(expense.id);
              debugPrint('✅ [SyncQueue] Sincronizado com Supabase e Hive atualizado: ${expense.id}');
            }
          } catch (e, st) {
            hadError = true;
            debugPrint('❌ [SyncQueue] Falha ao sincronizar (PUSH) ${expense.id}: ${e.runtimeType} — $e');
            debugPrintStack(stackTrace: st, maxFrames: 5);
            // Continua para a próxima despesa
          }
        }
      } else {
        debugPrint('📭 Fila de push vazia.');
      }

      // --- Passo 2: PULL (Busca remoto e mescla localmente) ---
      debugPrint('🔄 [SyncQueue] Iniciando Pull & Merge...');
      await _ref.read(syncPullServiceProvider).pullAndMerge();
    } catch (e) {
      hadError = true;
      debugPrint('❌ [SyncQueue] Erro geral no processQueue: $e');
    } finally {
      _isSyncing = false;
      // Notifica resultado final
      if (hadError) {
        _ref.read(syncStatusNotifierProvider.notifier).setError();
      } else {
        _ref.read(syncStatusNotifierProvider.notifier).setSuccess();
      }
    }
  }
}
