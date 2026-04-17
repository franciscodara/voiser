import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/core/constants/default_categories.dart';
import 'package:finwise/core/widgets/sync_status_badge.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseCard({super.key, required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final category = DefaultCategories.findByName(expense.categoryName);
    
    final icon = category?.icon ?? Icons.help_outline_rounded;
    final color = category?.color ?? theme.colorScheme.primary;

    return Dismissible(
      key: ValueKey(expense.id ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        expense.categoryName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const Spacer(),
                      SyncStatusBadge(synced: expense.synced),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              fmt.format(expense.amount),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
