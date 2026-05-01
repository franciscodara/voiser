import 'package:flutter/material.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

/// Utilitário centralizado de feedback visual.
/// Todos os snackbars do app devem usar esta classe para consistência.
class AppFeedback {
  AppFeedback._();

  static const _margin = EdgeInsets.fromLTRB(16, 0, 16, 16);
  static const _radius = 14.0;

  // ── Sucesso ──────────────────────────────────────────────────────────────
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppColors.primaryStatusPos,
    );
  }

  // ── Erro (com retry opcional) ─────────────────────────────────────────────
  static void error(
    BuildContext context,
    String message, {
    String retryLabel = 'Tentar novamente',
    VoidCallback? onRetry,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.primaryStatusNeg,
      action: onRetry != null
          ? SnackBarAction(
              label: retryLabel,
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
      duration: const Duration(seconds: 5),
    );
  }

  // ── Informação ────────────────────────────────────────────────────────────
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF0EA5E9),
      duration: const Duration(seconds: 2),
    );
  }

  // ── Undo (ação reversível) ────────────────────────────────────────────────
  static void undo(
    BuildContext context,
    String message, {
    required VoidCallback onUndo,
    String undoLabel = 'Desfazer',
  }) {
    _show(
      context,
      message: message,
      icon: Icons.undo_rounded,
      backgroundColor: const Color(0xFF1E293B),
      action: SnackBarAction(
        label: undoLabel,
        textColor: AppColors.primaryStatusPos,
        onPressed: onUndo,
      ),
      duration: const Duration(milliseconds: 1500),
    );
  }

  // ── Warning ────────────────────────────────────────────────────────────
  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      duration: const Duration(seconds: 3),
    );
  }

  // ── Privado ───────────────────────────────────────────────────────────────
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: _margin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        showCloseIcon: true,
        closeIconColor: Colors.white70,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
