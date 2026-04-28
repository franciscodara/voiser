import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';

/// Cabeçalho de grupo de data com totalizador do dia
class ExpenseGroupHeader extends StatelessWidget {
  final DateTime date;
  final List<Expense> expenses;

  const ExpenseGroupHeader({
    super.key,
    required this.date,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isToday = _isSameDay(date, DateTime.now());
    final isYesterday =
        _isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));

    String label;
    if (isToday) {
      label = 'Hoje';
    } else if (isYesterday) {
      label = 'Ontem';
    } else {
      label = DateFormat("dd 'de' MMMM", 'pt_BR').format(date);
    }

    // Totais do dia
    final totalExp = expenses
        .where((e) => e.type == TransactionType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);
    final totalInc = expenses
        .where((e) => e.type == TransactionType.income)
        .fold(0.0, (sum, e) => sum + e.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          // Label da data
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isToday
                  ? AppColors.primaryStatusPos
                  : theme.textTheme.bodySmall?.color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),

          const Spacer(),

          // Totais do dia (compacto)
          if (totalInc > 0)
            _DayTotal(
              value: fmt.format(totalInc),
              color: AppColors.primaryStatusPos,
              icon: Icons.north_east_rounded,
            ),

          if (totalInc > 0 && totalExp > 0)
            const SizedBox(width: 8),

          if (totalExp > 0)
            _DayTotal(
              value: fmt.format(totalExp),
              color: AppColors.primaryStatusNeg,
              icon: Icons.south_west_rounded,
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayTotal extends StatelessWidget {
  final String value;
  final Color color;
  final IconData icon;

  const _DayTotal({
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
