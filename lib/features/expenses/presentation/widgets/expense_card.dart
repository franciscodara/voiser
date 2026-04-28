import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/core/constants/default_categories.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  /// Callback disparado pelo swipe direita (sync + refresh).
  /// Opcional para compatibilidade com usos anteriores.
  final VoidCallback? onSync;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onDelete,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final timeFmt = DateFormat('HH:mm');

    final category = DefaultCategories.findByName(expense.categoryName);
    final icon = category?.icon ?? Icons.help_outline_rounded;
    final catColor = category?.color ?? theme.colorScheme.primary;

    final isIncome = expense.type == TransactionType.income;
    final accentColor = isIncome ? AppColors.primaryStatusPos : AppColors.primaryStatusNeg;

    return Dismissible(
      key: ValueKey(expense.id),
      // horizontal: startToEnd = sync (direita), endToStart = delete (esquerda)
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe direita → sync: não remove o item da lista
          onSync?.call();
          return false;
        }
        // Swipe esquerda → delete: remove o item (caller exibe snackbar undo)
        return true;
      },
      onDismissed: (_) => onDelete(),
      // background = startToEnd (swipe direita) → sync
      background: _SyncBackground(),
      // secondaryBackground = endToStart (swipe esquerda) → delete
      secondaryBackground: _DeleteBackground(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ── Barra lateral colorida ──────────────────────────
                Container(
                  width: 4,
                  color: accentColor,
                ),

                // ── Conteúdo principal ──────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    child: Row(
                      children: [
                        // Ícone da categoria
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: catColor, size: 22),
                        ),

                        const SizedBox(width: 13),

                        // Textos centrais
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Descrição ou categoria como título
                              Text(
                                expense.description?.isNotEmpty == true
                                    ? expense.description!
                                    : expense.categoryName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 3),

                              // Linha de meta: categoria + subcategoria
                              Row(
                                children: [
                                  // Chip de categoria
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: catColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      expense.categoryName,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: catColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (expense.subcategory?.isNotEmpty == true) ...[
                                    const SizedBox(width: 5),
                                    Text(
                                      '· ${expense.subcategory}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: theme.textTheme.bodySmall?.color,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Hora + sync status
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 11,
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    timeFmt.format(expense.date),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 11,
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _SyncDot(synced: expense.synced),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Valor
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isIncome ? '+' : '-'} ${fmt.format(expense.amount)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            if (isIncome)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryStatusPos.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Receita',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    color: AppColors.primaryStatusPos,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.04, duration: 250.ms),
    );
  }
}

// ── Widget de fundo do swipe sync (direita) ──────────────────────────────────

class _SyncBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sync_rounded, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            'Sincronizar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget de fundo do swipe delete (esquerda) ────────────────────────────────

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryStatusNeg,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            'Remover',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Indicador de sync compacto ───────────────────────────────────────────────

class _SyncDot extends StatelessWidget {
  final bool synced;
  const _SyncDot({required this.synced});

  @override
  Widget build(BuildContext context) {
    if (synced) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done_rounded, size: 12, color: Colors.green.shade400),
          const SizedBox(width: 3),
          Text(
            'Sync',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 12, color: Colors.orange.shade400),
        const SizedBox(width: 3),
        Text(
          'Pendente',
          style: TextStyle(
            fontSize: 10,
            color: Colors.orange.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
