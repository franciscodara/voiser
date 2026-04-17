import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
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

  Widget _buildHomeContent(WidgetRef ref, ThemeData theme) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final expensesAsync = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('FinWise', style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sair',
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-expense'),
        backgroundColor: AppColors.primaryStatusPos,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Boas-vindas ──────────────────────────────
            Text(
              'Olá, ${user == null ? 'Usuário' : user.displayName.split(' ').first}! 👋',
              style: AppTextStyles.headline,
            ).animate().fade(duration: 400.ms).slideX(begin: -0.1),

            const SizedBox(height: 4),

            Text(
              'O que vamos registrar hoje?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ).animate().fade(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ── Resumo rápido ────────────────────────────
            expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const _EmptyState()
                      .animate()
                      .fade(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1);
                }
                return _ExpenseSummaryCard(expenses: expenses)
                    .animate()
                    .fade(delay: 200.ms, duration: 400.ms);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
            ),

            const SizedBox(height: 24),

            // ── Ações rápidas ────────────────────────────
            Text(
              'Ações rápidas',
              style: AppTextStyles.label.copyWith(
                color: theme.textTheme.bodySmall?.color,
                letterSpacing: 0.8,
              ),
            ).animate().fade(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.edit_note_rounded,
                    label: 'Manual',
                    color: AppColors.primaryStatusPos,
                    onTap: () => context.push('/add-expense'),
                  ).animate().fade(delay: 360.ms, duration: 300.ms).slideY(begin: 0.15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.mic_rounded,
                    label: 'Por voz',
                    color: AppColors.catBar,
                    onTap: () => context.push('/voice-entry'),
                  ).animate().fade(delay: 400.ms, duration: 300.ms).slideY(begin: 0.15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Dashboard',
                    color: Colors.blueAccent,
                    onTap: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                  ).animate().fade(delay: 440.ms, duration: 300.ms).slideY(begin: 0.15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(ref, theme),
          const ExpenseListScreen(),
          const DashboardScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: AppColors.primaryStatusPos,
            unselectedItemColor: theme.textTheme.bodySmall?.color?.withOpacity(0.5) ?? Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
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

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma despesa ainda',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque no botão "+" para começar.',
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  final List<Expense> expenses;
  const _ExpenseSummaryCard({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final int incomesCount = expenses.where((e) => e.type.name == 'income').length;
    final int expensesCount = expenses.where((e) => e.type.name == 'expense').length;
    final int count = expenses.length;

    String subtitle = 'Pendente de sync com Sheets';
    if (count > 0) {
      if (incomesCount > 0 && expensesCount > 0) {
        subtitle = 'Sendo $incomesCount receita${incomesCount > 1 ? 's' : ''} e $expensesCount despesa${expensesCount > 1 ? 's' : ''}';
      } else if (incomesCount > 0) {
        subtitle = 'Pendente de sync com Sheets';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryStatusPos,
            AppColors.primaryStatusPos.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStatusPos.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count registro${count > 1 ? 's' : ''} efetuado${count > 1 ? 's' : ''}',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
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


class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
