import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finwise/core/providers/sync_status_provider.dart';
import 'package:finwise/core/services/sync_pull_service.dart';
import 'package:finwise/features/expenses/data/datasources/local/expense_hive_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/remote/supabase_datasource.dart';

part 'sync_queue_service.g.dart';

@Riverpod(keepAlive: true)
SyncQueueService syncQueueService(SyncQueueServiceRef ref) {
  return SyncQueueService(ref);
}

class SyncQueueService {
  final SyncQueueServiceRef _ref;
  bool _isSyncing = false;
  Completer<void>? _syncCompleter;

  SyncQueueService(this._ref);

  void startConnectivityListener() {
    Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
          debugPrint('[SyncQueue] Conectividade restaurada. Disparando sync.');
          processQueue();
        }
      },
    );
  }

  Future<void> processQueue({bool forcePull = false}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('[SyncQueue] Sessao ausente. Sincronizacao abortada.');
      return;
    }

    if (_isSyncing) {
      debugPrint('[SyncQueue] Sync em andamento. Aguardando conclusao.');
      await _syncCompleter?.future;
      if (forcePull) {
        await processQueue(forcePull: true);
      }
      return;
    }

    _isSyncing = true;
    _syncCompleter = Completer<void>();
    _ref.read(syncStatusNotifierProvider.notifier).setSyncing();

    bool hadError = false;

    try {
      final localDatasource = _ref.read(expenseHiveDatasourceProvider);
      final pendingExpenses = await localDatasource.getPendingExpenses();

      if (pendingExpenses.isNotEmpty) {
        debugPrint(
          '[SyncQueue] ${pendingExpenses.length} despesa(s) pendente(s) '
          'na fila (PUSH).',
        );

        final remoteDatasource = _ref.read(supabaseDatasourceProvider);

        for (final expense in pendingExpenses) {
          try {
            debugPrint(
              '[SyncQueue] Sincronizando: ${expense.id} | '
              'Deletado: ${expense.deleted}',
            );

            await remoteDatasource.upsertExpense(expense);

            if (expense.deleted || expense.deletedAt != null) {
              await localDatasource.deleteExpense(expense.id);
              debugPrint(
                '[SyncQueue] Soft delete enviado ao Supabase e removido '
                'do Hive: ${expense.id}',
              );
            } else {
              await localDatasource.markAsSynced(expense.id);
              debugPrint(
                '[SyncQueue] Sincronizado com Supabase e Hive atualizado: '
                '${expense.id}',
              );
            }
          } catch (e, st) {
            hadError = true;
            debugPrint(
              '[SyncQueue] Falha ao sincronizar (PUSH) ${expense.id}: '
              '${e.runtimeType} - $e',
            );
            debugPrintStack(stackTrace: st, maxFrames: 5);
          }
        }
      } else {
        debugPrint('[SyncQueue] Fila de push vazia.');
      }

      final localExpenses = await localDatasource.getAllExpenses();
      final shouldForcePull = forcePull || localExpenses.isEmpty;

      debugPrint(
        shouldForcePull
            ? '[SyncQueue] Iniciando Pull & Merge completo.'
            : '[SyncQueue] Iniciando Pull & Merge incremental.',
      );

      await _ref
          .read(syncPullServiceProvider)
          .pullAndMerge(forceFullSync: shouldForcePull);
    } catch (e) {
      hadError = true;
      debugPrint('[SyncQueue] Erro geral no processQueue: $e');
    } finally {
      _isSyncing = false;
      _syncCompleter?.complete();
      _syncCompleter = null;

      if (hadError) {
        _ref.read(syncStatusNotifierProvider.notifier).setError();
      } else {
        _ref.read(syncStatusNotifierProvider.notifier).setSuccess();
      }
    }
  }
}
