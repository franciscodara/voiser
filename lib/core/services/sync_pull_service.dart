import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finwise/features/expenses/data/datasources/local/expense_hive_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/remote/supabase_datasource.dart';
import 'package:finwise/core/services/sync_metadata_service.dart';

part 'sync_pull_service.g.dart';

@Riverpod(keepAlive: true)
SyncPullService syncPullService(SyncPullServiceRef ref) {
  return SyncPullService(ref);
}

class SyncPullService {
  final SyncPullServiceRef _ref;

  SyncPullService(this._ref);

  Future<void> pullAndMerge({bool forceFullSync = false}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('[SyncPull] Usuario nao autenticado. Abortando pull.');
      return;
    }

    try {
      final metadataService = _ref.read(syncMetadataServiceProvider);
      final lastSyncAt =
          forceFullSync ? null : await metadataService.getLastSyncAt();

      debugPrint(
        forceFullSync
            ? '[SyncPull] Pull completo iniciado.'
            : '[SyncPull] Buscando alteracoes remotas desde: $lastSyncAt',
      );

      final remoteDatasource = _ref.read(supabaseDatasourceProvider);
      final remoteExpenses =
          await remoteDatasource.fetchExpenses(updatedAfter: lastSyncAt);

      if (remoteExpenses.isEmpty) {
        debugPrint('[SyncPull] Nenhuma alteracao remota encontrada.');
        await metadataService.setLastSyncAt(DateTime.now());
        return;
      }

      debugPrint(
        '[SyncPull] Encontradas ${remoteExpenses.length} alteracoes remotas.',
      );

      final localDatasource = _ref.read(expenseHiveDatasourceProvider);
      final localExpensesList = await localDatasource.getAllExpenses();
      final localMap = {for (var e in localExpensesList) e.id: e};

      int inserted = 0;
      int updated = 0;
      int deleted = 0;

      for (final remote in remoteExpenses) {
        if (remote.deletedAt != null || remote.deleted) {
          if (localMap.containsKey(remote.id)) {
            await localDatasource.deleteExpense(remote.id);
            deleted++;
          }
          continue;
        }

        if (!localMap.containsKey(remote.id)) {
          await localDatasource.saveExpense(remote);
          inserted++;
        } else {
          final local = localMap[remote.id]!;
          final remoteUpdatedAt = remote.updatedAt ?? remote.date;
          final localUpdatedAt = local.updatedAt ?? local.date;

          if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
            await localDatasource.saveExpense(remote);
            updated++;
          }
        }
      }

      await metadataService.setLastSyncAt(DateTime.now());
      debugPrint(
        '[SyncPull] Merge concluido. Inseridos: $inserted | '
        'Atualizados: $updated | Deletados: $deleted',
      );
    } catch (e, st) {
      debugPrint('[SyncPull] Falha no pullAndMerge: $e');
      debugPrintStack(stackTrace: st, maxFrames: 5);
    }
  }
}
