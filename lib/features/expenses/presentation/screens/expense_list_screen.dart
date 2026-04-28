import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/services/sync_queue_service.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/utils/app_feedback.dart';
import 'package:finwise/core/widgets/shimmer_box.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finwise/features/expenses/presentation/widgets/expense_card.dart';
import 'package:finwise/features/expenses/presentation/widgets/expense_group_header.dart';

/// Enum de filtro de tipo de transação
enum _TransactionFilter { all, income, expense }

class ExpenseListScreen extends ConsumerStatefulWidget {
  /// Callback opcional para abrir o Drawer do Scaffold externo.
  /// Quando fornecido, exibe o ícone de hambúrguer no AppBar.
  final VoidCallback? onOpenDrawer;

  const ExpenseListScreen({super.key, this.onOpenDrawer});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  _TransactionFilter _filter = _TransactionFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _applyFilters(List<Expense> all) {
    var result = all;

    // Filtro por tipo
    if (_filter == _TransactionFilter.income) {
      result = result.where((e) => e.type == TransactionType.income).toList();
    } else if (_filter == _TransactionFilter.expense) {
      result = result.where((e) => e.type == TransactionType.expense).toList();
    }

    // Filtro de busca
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((e) {
        final desc = (e.description ?? '').toLowerCase();
        final cat = e.categoryName.toLowerCase();
        final sub = (e.subcategory ?? '').toLowerCase();
        return desc.contains(q) || cat.contains(q) || sub.contains(q);
      }).toList();
    }

    return result;
  }

  Map<DateTime, List<Expense>> _groupByDate(List<Expense> expenses) {
    final map = <DateTime, List<Expense>>{};
    for (var exp in expenses) {
      final key = DateTime(exp.date.year, exp.date.month, exp.date.day);
      map.putIfAbsent(key, () => []).add(exp);
    }
    return map;
  }

  void _handleDelete(BuildContext context, Expense expense) {
    HapticFeedback.mediumImpact();
    ref.read(expenseNotifierProvider.notifier).deleteExpense(expense.id);

    AppFeedback.undo(
      context,
      'Transação removida',
      onUndo: () {
        ref.read(expenseNotifierProvider.notifier).addExpense(
              expense.copyWith(deleted: false, synced: false),
            );
      },
    );
  }

  /// Swipe direita: atualiza lista local e dispara sync da fila pendente.
  Future<void> _handleSync(BuildContext context) async {
    await ref.read(expenseNotifierProvider.notifier).refreshExpenses();
    ref.read(syncQueueServiceProvider).processQueue();

    if (!context.mounted) return;
    AppFeedback.info(context, 'Sincronizando com Google Sheets...');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(expenseNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Menu',
                onPressed: widget.onOpenDrawer,
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar descrição, categoria...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  border: InputBorder.none,
                ),
                style: AppTextStyles.bodyMedium,
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text('Transações', style: AppTextStyles.title),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(expenseNotifierProvider.notifier).refreshExpenses(),
          ),
        ],
      ),
      body: expensesAsync.when(
        loading: () => _ExpenseListSkeleton(),
        error: (e, _) => _ListErrorState(
          message: 'Não foi possível carregar as transações.',
          onRetry: () =>
              ref.read(expenseNotifierProvider.notifier).refreshExpenses(),
        ),
        data: (allExpenses) {
          final filtered = _applyFilters(allExpenses);
          final grouped = _groupByDate(filtered);
          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              // ── Totalizador ──────────────────────────────────────
              _PeriodSummary(expenses: filtered)
                  .animate()
                  .fadeIn(duration: 300.ms),

              // ── Chips de filtro ───────────────────────────────────
              _FilterChips(
                selected: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

              // ── Lista ─────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(
                        hasSearch: _searchQuery.isNotEmpty,
                        filter: _filter,
                      ).animate().fadeIn(delay: 150.ms)
                    : RefreshIndicator(
                        onRefresh: () async => ref
                            .read(expenseNotifierProvider.notifier)
                            .refreshExpenses(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: sortedKeys.length,
                          itemBuilder: (context, i) {
                            final date = sortedKeys[i];
                            final dayExpenses = grouped[date]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ExpenseGroupHeader(
                                  date: date,
                                  expenses: dayExpenses,
                                ),
                                ...dayExpenses.map(
                                  (exp) => ExpenseCard(
                                    expense: exp,
                                    onDelete: () => _handleDelete(context, exp),
                                    onSync: () => _handleSync(context),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Totalizador do Período ────────────────────────────────────────────────────

class _PeriodSummary extends StatelessWidget {
  final List<Expense> expenses;
  const _PeriodSummary({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final totalInc = expenses
        .where((e) => e.type == TransactionType.income)
        .fold(0.0, (s, e) => s + e.amount);
    final totalExp = expenses
        .where((e) => e.type == TransactionType.expense)
        .fold(0.0, (s, e) => s + e.amount);
    final balance = totalInc - totalExp;
    final isPositive = balance >= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          _SummaryItem(
            label: 'Entradas',
            value: fmt.format(totalInc),
            color: AppColors.primaryStatusPos,
            icon: Icons.north_east_rounded,
          ),
          const _Divider(),
          _SummaryItem(
            label: 'Saídas',
            value: fmt.format(totalExp),
            color: AppColors.primaryStatusNeg,
            icon: Icons.south_west_rounded,
          ),
          const _Divider(),
          _SummaryItem(
            label: 'Saldo',
            value: fmt.format(balance),
            color: isPositive ? AppColors.primaryStatusPos : AppColors.primaryStatusNeg,
            icon: isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool bold;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
        height: 32,
        width: 1,
        color: Theme.of(context).dividerColor.withOpacity(0.2),
      );
}

// ── Chips de Filtro ───────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final _TransactionFilter selected;
  final ValueChanged<_TransactionFilter> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _Chip(
            label: 'Tudo',
            selected: selected == _TransactionFilter.all,
            onTap: () => onChanged(_TransactionFilter.all),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Receitas',
            selected: selected == _TransactionFilter.income,
            onTap: () => onChanged(_TransactionFilter.income),
            color: AppColors.primaryStatusPos,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Despesas',
            selected: selected == _TransactionFilter.expense,
            onTap: () => onChanged(_TransactionFilter.expense),
            color: AppColors.primaryStatusNeg,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : theme.dividerColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? Colors.white : theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final _TransactionFilter filter;

  const _EmptyState({required this.hasSearch, required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String subtitle;
    IconData icon;

    if (hasSearch) {
      title = 'Nenhum resultado';
      subtitle = 'Tente buscar por outro termo.';
      icon = Icons.search_off_rounded;
    } else if (filter == _TransactionFilter.income) {
      title = 'Sem receitas';
      subtitle = 'Nenhuma receita registrada ainda.';
      icon = Icons.north_east_rounded;
    } else if (filter == _TransactionFilter.expense) {
      title = 'Sem despesas';
      subtitle = 'Nenhuma despesa registrada ainda.';
      icon = Icons.south_west_rounded;
    } else {
      title = 'Nenhuma transação';
      subtitle = 'Adicione despesas ou receitas para começar.';
      icon = Icons.receipt_long_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.25),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.title.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton da Lista ─────────────────────────────────────────────────────────

class _ExpenseListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: 6,
      itemBuilder: (_, i) => const ExpenseCardSkeleton(),
    );
  }
}

// ── Error State da Lista ──────────────────────────────────────────────────────

class _ListErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ListErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppColors.primaryStatusNeg.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: AppTextStyles.title.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tentar novamente'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryStatusPos,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
