import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

class ExpenseGroupHeader extends StatelessWidget {
  final DateTime date;
  
  const ExpenseGroupHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(date, DateTime.now());
    final isYesterday = _isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));
    
    String label;
    if (isToday) {
      label = 'Hoje';
    } else if (isYesterday) {
      label = 'Ontem';
    } else {
      label = DateFormat("dd 'de' MMMM", 'pt_BR').format(date);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: theme.textTheme.bodySmall?.color,
          fontSize: 14,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
