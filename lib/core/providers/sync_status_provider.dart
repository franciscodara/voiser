import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

/// Estados possíveis de sincronização global.
enum SyncStatus {
  /// Nenhuma operação de sync em andamento.
  idle,

  /// Sync em progresso — fila sendo processada.
  syncing,

  /// Sync concluído com sucesso.
  success,

  /// Erro durante o sync — UI deve oferecer retry.
  error,
}

/// Estado global de sincronização exposto para a UI.
@Riverpod(keepAlive: true)
class SyncStatusNotifier extends _$SyncStatusNotifier {
  @override
  SyncStatus build() => SyncStatus.idle;

  void setSyncing() {
    state = SyncStatus.syncing;
  }

  void setSuccess() {
    state = SyncStatus.success;
    // Auto-reset para idle após 3 segundos para a UI mostrar o feedback
    Future.delayed(const Duration(seconds: 3), () {
      if (state == SyncStatus.success) {
        state = SyncStatus.idle;
      }
    });
  }

  void setError() {
    state = SyncStatus.error;
  }

  void setIdle() {
    state = SyncStatus.idle;
  }
}
