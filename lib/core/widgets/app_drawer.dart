import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/widgets/drawer_header.dart';
import 'package:finwise/core/widgets/drawer_item.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';

/// Drawer lateral principal do FinWise.
/// Contém header com dados do usuário + itens de conta e sistema.
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  /// Rota do item atualmente destacado (highlight temporário).
  String? _activeRoute;

  /// Evita múltiplos cliques simultâneos durante a animação de fechamento.
  bool _isNavigating = false;

  /// Fecha o drawer e executa a ação após a animação (16ms de grace).
  void _navigate(String route) {
    if (_isNavigating) return;

    setState(() {
      _activeRoute = route;
      _isNavigating = true;
    });

    // Fecha o drawer primeiro
    Navigator.of(context).pop();

    // Pequeno delay para a animação de fechamento antes de navegar
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _activeRoute = null;
        _isNavigating = false;
      });
      context.push(route);
    });
  }

  /// Para ações que não são navegação (ex: logout).
  void _runAction(VoidCallback action) {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _isNavigating = false);
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).valueOrNull;

    final displayName = user?.displayName ?? 'Usuário';
    final email = user?.email ?? '';

    return Drawer(
      width: 300,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          AppDrawerHeader(
            displayName: displayName,
            email: email,
            plan: 'Free',
          ),

          // ── Itens ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Seção: Conta ───────────────────────────────────
                  _SectionLabel(label: 'CONTA'),

                  DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Minha conta',
                    iconColor: AppColors.primaryStatusPos,
                    isActive: _activeRoute == '/profile',
                    showDivider: true,
                    onTap: () => _navigate('/profile'),
                  ),

                  DrawerItem(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Assinatura',
                    iconColor: const Color(0xFFFBBF24),
                    isActive: _activeRoute == '/subscription',
                    badge: 'Em breve',
                    showDivider: true,
                    onTap: () => _navigate('/subscription'),
                  ),

                  DrawerItem(
                    icon: Icons.headset_mic_outlined,
                    label: 'Fale conosco',
                    iconColor: const Color(0xFF6366F1),
                    isActive: _activeRoute == '/support',
                    showDivider: false,
                    onTap: () => _navigate('/support'),
                  ),

                  const SizedBox(height: 8),

                  // ── Seção: Sistema ─────────────────────────────────
                  _SectionLabel(label: 'SISTEMA'),

                  DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Configurações',
                    iconColor: AppColors.catBills,
                    isActive: _activeRoute == '/settings',
                    showDivider: false,
                    onTap: () => _navigate('/settings'),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      color: theme.dividerColor.withValues(alpha: 0.15),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Sair ───────────────────────────────────────────
                  DrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'Sair',
                    isDestructive: true,
                    onTap: () => _runAction(
                      () => ref.read(authNotifierProvider.notifier).signOut(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Footer com versão ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 13,
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 6),
                Text(
                  'FinWise  ·  v1.0.0',
                  style: AppTextStyles.label.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label de seção ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
