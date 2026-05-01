import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/widgets/app_drawer.dart';
import 'package:finwise/core/widgets/shimmer_box.dart';
import 'package:finwise/core/widgets/speed_dial_fab.dart';
import 'package:finwise/core/widgets/sync_status_banner.dart';
import 'package:finwise/core/services/sync_queue_service.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:finwise/features/dashboard/presentation/dashboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Chave para acessar o Scaffold externo (usado para abrir o Drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fecha o SpeedDial quando muda de aba
  final GlobalKey<_HomeContentState> _homeKey = GlobalKey();

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void openDrawer() => _scaffoldKey.currentState?.openDrawer();

    final pages = [
      _HomeContent(
        key: _homeKey,
        onNavigateTo: _onTabTapped,
        onOpenDrawer: openDrawer,
      ),
      ExpenseListScreen(onOpenDrawer: openDrawer),
      DashboardScreen(onOpenDrawer: openDrawer),
    ];

    return Scaffold(
      key: _scaffoldKey,
      // Drawer fica no Scaffold raiz para sobrepor todas as abas
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton:
          _currentIndex == 0 ? const SpeedDialFab() : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: AppColors.primaryStatusPos,
            unselectedItemColor:
                theme.textTheme.bodySmall?.color?.withOpacity(0.5) ??
                    Colors.grey,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Transações',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Dashboard',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Conteúdo da Home ─────────────────────────────────────────────────────────

class _HomeContent extends ConsumerStatefulWidget {
  final void Function(int index) onNavigateTo;
  /// Callback para abrir o Drawer do Scaffold externo.
  final VoidCallback onOpenDrawer;

  const _HomeContent({
    super.key,
    required this.onNavigateTo,
    required this.onOpenDrawer,
  });

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final expensesAsync = ref.watch(expenseNotifierProvider);
    final firstName =
        user?.email?.split('@').first ?? 'Usuário';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Chama diretamente o Scaffold externo via callback — evita
        // o problema de Scaffold.of() resolver o Scaffold interno.
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Menu',
          onPressed: widget.onOpenDrawer,
        ),
        title: Text('Voiser', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Banner global de sync/offline ──────────────────────
          SyncStatusBanner(
            onRetrySync: () =>
                ref.read(syncQueueServiceProvider).processQueue(),
          ),

          // ── Conteúdo principal ─────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.read(expenseNotifierProvider.notifier).refreshExpenses(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Saudação ──────────────────────────────────────────
                    Text(
                      'Olá, $firstName! 👋',
                      style: AppTextStyles.headline,
                    ).animate().fade(duration: 400.ms).slideX(begin: -0.08),

                    const SizedBox(height: 4),

                    Text(
                      'O que vamos registrar hoje?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ).animate().fade(delay: 80.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // ── Resumo do mês ─────────────────────────────────────
                    expensesAsync.when(
                      loading: () => const SummaryCardSkeleton(),
                      error: (e, _) => _ErrorCard(
                        message: 'Não foi possível carregar o resumo.',
                        onRetry: () => ref
                            .read(expenseNotifierProvider.notifier)
                            .refreshExpenses(),
                      ),
                      data: (expenses) => _MonthSummaryCard(
                        expenses: expenses,
                        onViewAll: () => widget.onNavigateTo(1),
                      ).animate().fade(delay: 150.ms, duration: 400.ms).slideY(begin: 0.08),
                    ),

                    const SizedBox(height: 28),

                    // ── Ações rápidas ─────────────────────────────────────
                    Text(
                      'AÇÕES RÁPIDAS',
                      style: AppTextStyles.label.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ).animate().fade(delay: 250.ms, duration: 400.ms),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.edit_note_rounded,
                            label: 'Manual',
                            description: 'Digitar entrada',
                            color: AppColors.primaryStatusPos,
                            onTap: () => context.push('/add-expense'),
                          ).animate()
                              .fade(delay: 300.ms, duration: 300.ms)
                              .slideY(begin: 0.12),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.mic_rounded,
                            label: 'Por voz',
                            description: 'Falar e registrar',
                            color: AppColors.catBar,
                            onTap: () => context.push('/voice-entry'),
                          ).animate()
                              .fade(delay: 350.ms, duration: 300.ms)
                              .slideY(begin: 0.12),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.bar_chart_rounded,
                            label: 'Dashboard',
                            description: 'Ver gráficos',
                            color: const Color(0xFF6366F1),
                            onTap: () => widget.onNavigateTo(2),
                          ).animate()
                              .fade(delay: 400.ms, duration: 300.ms)
                              .slideY(begin: 0.12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Transações recentes ───────────────────────────────
                    expensesAsync.maybeWhen(
                      data: (expenses) {
                        if (expenses.isEmpty) return const SizedBox.shrink();
                        return _RecentTransactions(
                          expenses: expenses.take(5).toList(),
                          onViewAll: () => widget.onNavigateTo(1),
                        ).animate().fade(delay: 450.ms, duration: 400.ms);
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card de Resumo do Mês ─────────────────────────────────────────────────────

class _MonthSummaryCard extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback onViewAll;

  const _MonthSummaryCard({
    required this.expenses,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final now = DateTime.now();

    final thisMonth = expenses.where(
      (e) => e.date.month == now.month && e.date.year == now.year,
    );

    final totalInc = thisMonth
        .where((e) => e.type == TransactionType.income)
        .fold(0.0, (s, e) => s + e.amount);
    final totalExp = thisMonth
        .where((e) => e.type == TransactionType.expense)
        .fold(0.0, (s, e) => s + e.amount);
    final balance = totalInc - totalExp;
    final isPositive = balance >= 0;
    final count = thisMonth.length;

    final monthLabel = DateFormat("MMMM 'de' yyyy", 'pt_BR')
        .format(now)
        .toLowerCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF065F46), const Color(0xFF10B981)]
              : [const Color(0xFF7F1D1D), const Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPositive
                    ? AppColors.primaryStatusPos
                    : AppColors.primaryStatusNeg)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: Colors.white60,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                monthLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'Ver tudo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 12),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            fmt.format(balance),
            style: AppTextStyles.headline.copyWith(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Saldo disponível · $count registro${count != 1 ? 's' : ''}',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
          ),

          const SizedBox(height: 16),

          // Mini linha de Entradas/Saídas
          Row(
            children: [
              _MiniStat(
                icon: Icons.north_east_rounded,
                label: 'Entradas',
                value: fmt.format(totalInc),
                color: Colors.greenAccent.shade200,
              ),
              const SizedBox(width: 24),
              _MiniStat(
                icon: Icons.south_west_rounded,
                label: 'Saídas',
                value: fmt.format(totalExp),
                color: Colors.red.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            Text(
              value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

// ── Error Card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.primaryStatusNeg.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 36, color: AppColors.primaryStatusNeg.withOpacity(0.7)),
          const SizedBox(height: 8),
          Text(message,
              style: AppTextStyles.bodySmall
                  .copyWith(color: theme.textTheme.bodySmall?.color),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Tentar novamente'),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryStatusPos),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: _pressed
                ? theme.colorScheme.surface.withOpacity(0.8)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _pressed
                  ? widget.color.withOpacity(0.4)
                  : theme.dividerColor.withOpacity(0.15),
            ),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: AppTextStyles.label.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                widget.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Transações Recentes ───────────────────────────────────────────────────────

class _RecentTransactions extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback onViewAll;

  const _RecentTransactions({
    required this.expenses,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final timeFmt = DateFormat('dd/MM · HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'RECENTES',
              style: AppTextStyles.label.copyWith(
                color: theme.textTheme.bodySmall?.color,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'Ver todas',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryStatusPos,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: theme.dividerColor.withOpacity(0.1),
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, i) {
              final exp = expenses[i];
              final isIncome = exp.type == TransactionType.income;
              final accentColor = isIncome
                  ? AppColors.primaryStatusPos
                  : AppColors.primaryStatusNeg;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Dot colorido
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Descrição + data
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.description?.isNotEmpty == true
                                ? exp.description!
                                : exp.categoryName,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            timeFmt.format(exp.date),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Valor
                    Text(
                      '${isIncome ? '+' : '-'} ${fmt.format(exp.amount)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
