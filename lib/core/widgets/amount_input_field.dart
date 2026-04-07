import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_colors.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: 'R\$ 0,00');
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

    double value = double.parse(digitsOnly) / 100;
    
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    String newText = formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isExpense;
  
  const AmountInputField({
    super.key, 
    required this.controller,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isExpense ? AppColors.primaryStatusNeg : AppColors.primaryStatusPos;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      textAlign: TextAlign.center,
      style: AppTextStyles.display.copyWith(
        color: color,
        fontSize: 48,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'R\$ 0,00',
        hintStyle: AppTextStyles.display.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.3),
          fontSize: 48,
        ),
      ),
    );
  }
}
