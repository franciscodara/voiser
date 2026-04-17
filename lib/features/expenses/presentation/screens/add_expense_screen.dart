import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/constants/default_categories.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/widgets/amount_input_field.dart';
import 'package:finwise/core/widgets/finwise_button.dart';
import 'package:finwise/features/expenses/domain/entities/category.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finwise/features/expenses/presentation/widgets/category_selector.dart';
import 'package:go_router/go_router.dart';


class AddExpenseScreen extends ConsumerStatefulWidget {
  final double? initialAmount;
  final String? initialDescription;
  final String? initialCategoryName;
  final String? initialSubcategory;

  const AddExpenseScreen({
    super.key,
    this.initialAmount,
    this.initialDescription,
    this.initialCategoryName,
    this.initialSubcategory,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  Category? _selectedCategory;
  String? _selectedSubcategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isExpense = true;

  @override
  void initState() {
    super.initState();
    _applyPrefill();
  }

  void _applyPrefill() {
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 2,
      ).format(widget.initialAmount);
    }

    if (widget.initialDescription != null && widget.initialDescription!.trim().isNotEmpty) {
      _descriptionController.text = widget.initialDescription!.trim();
    }

    if (widget.initialCategoryName != null) {
      final category = DefaultCategories.findByName(widget.initialCategoryName!);
      if (category != null) {
        _selectedCategory = category;

        if (widget.initialSubcategory != null &&
            category.subcategories.contains(widget.initialSubcategory)) {
          _selectedSubcategory = widget.initialSubcategory;
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────

  double get _parsedAmount {
    final raw = _amountController.text.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.');
    return double.tryParse(raw) ?? 0.0;
  }

  bool get _isFormValid => _selectedCategory != null && _parsedAmount > 0;

  String _generateId() {
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    return '${DateTime.now().millisecondsSinceEpoch}-$rand';
  }

  // ── Actions ──────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time?.hour ?? _selectedDate.hour,
          time?.minute ?? _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_isFormValid) {
      _showError(_parsedAmount <= 0 ? 'Informe um valor.' : 'Selecione uma categoria.');
      return;
    }

    setState(() => _isSaving = true);

    final expense = Expense(
      id: _generateId(),
      date: _selectedDate,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      subcategory: _selectedSubcategory,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      amount: _parsedAmount,
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      origin: EntryOrigin.manual,
      synced: false,
    );

    await ref.read(expenseNotifierProvider.notifier).addExpense(expense);

    if (mounted) {
      setState(() => _isSaving = false);
      _showSuccess(expense);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryStatusNeg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(Expense expense) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              _isExpense ? 'Despesa salva! ↩️' : 'Receita salva! 💵',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryStatusPos,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DESFAZER',
          textColor: Colors.white,
          onPressed: () {
            ref.read(expenseNotifierProvider.notifier).deleteExpense(expense.id);
          },
        ),
      ),
    );

    // Limpa o formulário após salvar
    setState(() {
      _amountController.clear();
      _selectedCategory = null;
      _selectedSubcategory = null;
      _descriptionController.clear();
      _selectedDate = DateTime.now();
    });
    _scrollController.animateTo(0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isExpense ? 'Adicionar Despesa' : 'Nova Receita', style: AppTextStyles.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Link rápido para voz
          TextButton.icon(
            onPressed: () {
              // TODO(bloco-voz): navegar para VoiceEntryScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎤 Voz disponível no próximo bloco!')),
              );
            },
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: const Text('Usar voz'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Segmented Control Despesa/Receita ───────────
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton(
                      title: 'Despesa',
                      isSelected: _isExpense,
                      activeColor: Colors.redAccent,
                      onTap: () => setState(() {
                        _isExpense = true;
                        _selectedCategory = null;
                        _selectedSubcategory = null;
                      }),
                    ),
                    _buildToggleButton(
                      title: 'Receita',
                      isSelected: !_isExpense,
                      activeColor: Colors.green,
                      onTap: () => setState(() {
                        _isExpense = false;
                        _selectedCategory = null;
                        _selectedSubcategory = null;
                      }),
                    ),
                  ],
                ),
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: -0.2),

            const SizedBox(height: 24),

            // ── Campo Valor ──────────────────────────────
            _SectionCard(
              child: Column(
                children: [
                  Text(
                    _isExpense ? 'Quanto foi gasto?' : 'Quanto recebeu?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AmountInputField(
                    controller: _amountController,
                    isExpense: _isExpense,
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: 0.15),

            const SizedBox(height: 16),

            // ── Categorias ───────────────────────────────
            _SectionLabel(label: 'Categoria', icon: Icons.grid_view_rounded)
                .animate()
                .fade(delay: 80.ms, duration: 300.ms),

            const SizedBox(height: 10),

            CategorySelector(
              selected: _selectedCategory,
              isExpense: _isExpense,
              onSelected: (cat) {
                setState(() {
                  _selectedCategory = cat;
                  _selectedSubcategory = null; // reset subcategoria
                });
              },
            ).animate().fade(delay: 120.ms, duration: 300.ms),

            const SizedBox(height: 16),

            // ── Sub-categoria ────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _selectedCategory != null && _selectedCategory!.subcategories.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(
                          label: 'Sub-categoria',
                          icon: Icons.subdirectory_arrow_right_rounded,
                        ),
                        const SizedBox(height: 10),
                        _SubcategoryDropdown(
                          subcategories: _selectedCategory!.subcategories,
                          selected: _selectedSubcategory,
                          accentColor: _selectedCategory!.color,
                          onChanged: (val) => setState(() => _selectedSubcategory = val),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Data e Hora ──────────────────────────────
            _SectionLabel(label: 'Data e Hora', icon: Icons.calendar_today_rounded)
                .animate()
                .fade(delay: 200.ms, duration: 300.ms),

            const SizedBox(height: 10),

            _DateTimePicker(
              date: _selectedDate,
              onTap: _pickDate,
            ).animate().fade(delay: 240.ms, duration: 300.ms),

            const SizedBox(height: 16),

            // ── Descrição ────────────────────────────────
            _SectionLabel(label: 'Descrição', icon: Icons.notes_rounded, optional: true)
                .animate()
                .fade(delay: 280.ms, duration: 300.ms),

            const SizedBox(height: 10),

            _DescriptionField(
              controller: _descriptionController,
              isDark: isDark,
            ).animate().fade(delay: 300.ms, duration: 300.ms),

            const SizedBox(height: 28),

            // ── Botão Salvar ─────────────────────────────
            FinwiseButton(
              text: _isExpense ? 'Salvar despesa' : 'Salvar receita',
              isLoading: _isSaving,
              onPressed: _save,
            ).animate().fade(delay: 360.ms, duration: 300.ms).slideY(begin: 0.3),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets privados ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool optional;

  const _SectionLabel({
    required this.label,
    required this.icon,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            '(opcional)',
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ],
    );
  }
}

class _SubcategoryDropdown extends StatelessWidget {
  final List<String> subcategories;
  final String? selected;
  final Color accentColor;
  final ValueChanged<String?> onChanged;

  const _SubcategoryDropdown({
    required this.subcategories,
    required this.selected,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected != null ? accentColor.withOpacity(0.6) : theme.dividerColor.withOpacity(0.3),
          width: selected != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text(
            'Selecione...',
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
          isExpanded: true,
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          items: subcategories
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: AppTextStyles.bodyMedium),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateTimePicker({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
    final timeStr = DateFormat('HH:mm').format(date);
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Hoje' : dateStr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const _DescriptionField({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      maxLines: 2,
      maxLength: 120,
      textCapitalization: TextCapitalization.sentences,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Ex: Compras da semana no Extra...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
        ),
        counterStyle: AppTextStyles.bodySmall.copyWith(
          color: theme.textTheme.bodySmall?.color,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.7),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
