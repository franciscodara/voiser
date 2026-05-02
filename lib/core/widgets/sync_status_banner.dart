import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/providers/connectivity_provider.dart';
import 'package:finwise/core/providers/sync_status_provider.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

/// Banner global discreto que indica:
/// - Modo offline (âmbar persistente)
/// - Sync em progresso (azul animado)
/// - Sucesso no sync (verde com auto-dismiss)
/// - Erro no sync (vermelho com retry)
///
/// Deve ser inserido no topo do body principal (HomeScreen, etc.)
class SyncStatusBanner extends ConsumerWidget {
  /// Callback para retry manual do sync
  final VoidCallback? onRetrySync;

  const SyncStatusBanner({super.key, this.onRetrySync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusNotifierProvider);
    final offlineAsync = ref.watch(isOfflineProvider);
    final isOffline = offlineAsync.valueOrNull ?? false;

    // Prioridade: offline > syncing > success > error > nada
    if (isOffline) {
      return _BannerTile(
        icon: Icons.wifi_off_rounded,
        message: 'Modo offline · dados salvos localmente',
        backgroundColor: const Color(0xFFF59E0B),
        animated: false,
      );
    }

    switch (syncStatus) {
      case SyncStatus.syncing:
        return _BannerTile(
          icon: Icons.sync_rounded,
          message: 'Sincronizando dados...',
          backgroundColor: const Color(0xFF0EA5E9),
          animated: true,
        );

      case SyncStatus.success:
        return _BannerTile(
          icon: Icons.cloud_done_rounded,
          message: 'Sincronizado com sucesso!',
          backgroundColor: AppColors.primaryStatusPos,
          animated: false,
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .then(delay: 2500.ms)
            .fadeOut(duration: 400.ms);

      case SyncStatus.error:
        return _BannerTile(
          icon: Icons.cloud_off_rounded,
          message: 'Falha na sincronização',
          backgroundColor: AppColors.primaryStatusNeg,
          animated: false,
          trailing: onRetrySync != null
              ? GestureDetector(
                  onTap: onRetrySync,
                  child: Text(
                    'Tentar novamente',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                )
              : null,
        );

      case SyncStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

class _BannerTile extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color backgroundColor;
  final bool animated;
  final Widget? trailing;

  const _BannerTile({
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.animated,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = animated
        ? Icon(icon, color: Colors.white, size: 15)
            .animate(onPlay: (c) => c.repeat())
            .rotate(duration: 800.ms)
        : Icon(icon, color: Colors.white, size: 15);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.5);
  }
}
