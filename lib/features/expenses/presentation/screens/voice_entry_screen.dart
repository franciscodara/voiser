import 'dart:async';
import 'dart:math';

import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/constants/default_categories.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/features/expenses/domain/entities/expense.dart';
import 'package:finwise/features/expenses/domain/entities/voice_command_result.dart';
import 'package:finwise/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finwise/features/expenses/presentation/providers/voice_input_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VoiceEntryScreen extends ConsumerStatefulWidget {
  final String? initialText;

  const VoiceEntryScreen({super.key, this.initialText});

  @override
  ConsumerState<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

class _VoiceEntryScreenState extends ConsumerState<VoiceEntryScreen> {
  Timer? _countdownTimer;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialText != null && widget.initialText!.isNotEmpty) {
        ref.read(voiceInputNotifierProvider.notifier).processDirectText(widget.initialText!);
      } else {
        ref.read(voiceInputNotifierProvider.notifier).startListening();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startConfirmationTimer(Expense expense) {
    _countdownTimer?.cancel();
    setState(() => _countdown = 3);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown == 1) {
        timer.cancel();
        _confirmExpense(expense);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _showSuccessAndPop(Expense expense) {
    if (!mounted) return;

    ref.read(voiceInputNotifierProvider.notifier).confirm();
    ref.read(expenseNotifierProvider.notifier).addExpense(expense);
    _countdownTimer?.cancel();

    // Mostra feedback, depois volta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              expense.type == TransactionType.income
                  ? 'Receita salva com sucesso!'
                  : 'Despesa registrada por voz!',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryStatusPos,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
    context.pop();
  }

  void _confirmExpense(Expense expense) => _showSuccessAndPop(expense);

  void _openManualFallback(VoiceCommandResult result) {
    final queryParameters = <String, String>{};
    if (result.amount > 0) {
      queryParameters['amount'] = result.amount.toString();
    }
    if (result.description != null && result.description!.trim().isNotEmpty) {
      queryParameters['description'] = result.description!.trim();
    }
    if (result.category.trim().isNotEmpty) {
      queryParameters['categoryName'] = result.category;
    }
    if (result.subcategory != null && result.subcategory!.trim().isNotEmpty) {
      queryParameters['subcategory'] = result.subcategory!.trim();
    }

    ref.read(voiceInputNotifierProvider.notifier).consumeManualFallback();
    context.pushReplacement(Uri(path: '/add-expense', queryParameters: queryParameters).toString());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VoiceInputState>(voiceInputNotifierProvider, (previous, next) {
      if (next.status == VoiceInputStateStatus.manualFallback &&
          next.result != null &&
          previous?.status != VoiceInputStateStatus.manualFallback) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _openManualFallback(next.result!);
          }
        });
      }
    });

    final state = ref.watch(voiceInputNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            ref.read(voiceInputNotifierProvider.notifier).cancel();
            context.pop();
          },
        ),
        title: Text(
          _statusLabel(state.status),
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildCenterArea(state),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildStatusText(state),
            ),
            const Spacer(),
            if (state.status == VoiceInputStateStatus.confirming &&
                state.result != null)
              _buildConfirmationCard(state)
            else if (state.status == VoiceInputStateStatus.error)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.mic_off_rounded,
                        size: 36,
                        color: AppColors.primaryStatusNeg.withOpacity(0.8)),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Erro desconhecido.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryStatusNeg,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => ref
                          .read(voiceInputNotifierProvider.notifier)
                          .startListening(),
                      icon: const Icon(Icons.mic_rounded, size: 18),
                      label: const Text('Tentar novamente'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryStatusPos,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: state.status == VoiceInputStateStatus.listening
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(voiceInputNotifierProvider.notifier).stopAndProcess();
              },
              backgroundColor: AppColors.primaryStatusPos.withOpacity(0.9),
              elevation: 0,
              label: Text('Parar agora',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCenterArea(VoiceInputState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.status == VoiceInputStateStatus.processing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.catBar)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(end: 1.2),
            const SizedBox(height: 20),
            Text(
              'Processando…',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final isListening = state.status == VoiceInputStateStatus.listening;
    final circleColor = isListening
        ? AppColors.catBar.withOpacity(0.2)
        : theme.colorScheme.surface.withOpacity(0.5);
    final iconColor = isListening ? AppColors.catBar : theme.disabledColor;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circleColor,
        ),
        child: Icon(Icons.mic_none_outlined, size: 80, color: iconColor),
      )
          .animate(target: isListening ? 1 : 0)
          .scaleXY(end: 1.15, duration: 1000.ms, curve: Curves.easeInOutSine)
          .tint(color: AppColors.catBar.withOpacity(0.3)),
    );
  }

  Widget _buildConfirmationCard(VoiceInputState state) {
    final result = state.result!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final expense = Expense(
      id: '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}',
      date: DateTime.now(),
      categoryId: result.type == 'income'
          ? 'income'
          : (DefaultCategories.findByName(result.category)?.id ?? 'other'),
      categoryName: result.category,
      subcategory: result.subcategory,
      description: result.description,
      amount: result.amount,
      type: result.type == 'income' ? TransactionType.income : TransactionType.expense,
      origin: EntryOrigin.voice,
      synced: false,
    );

    if (_countdown == 3 && _countdownTimer == null) {
      _startConfirmationTimer(expense);
    }

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600;
    final chipBg = isDark
        ? AppColors.catBar.withOpacity(0.15)
        : Colors.purple.shade50;
    final chipIcon =
        isDark ? AppColors.catBar : Colors.purple.shade400;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: chipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: chipIcon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'R\$ ${result.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${result.category}${result.subcategory != null ? ' • ${result.subcategory}' : ''}',
                      style: TextStyle(fontSize: 16, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (result.description != null && result.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '"${result.description}"',
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: textSecondary),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            result.type == 'income'
                ? 'Receita detectada por voz'
                : 'Despesa detectada por voz',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _countdownTimer?.cancel();
                    ref.read(voiceInputNotifierProvider.notifier).cancel();
                  },
                  child: Text('Cancelar',
                      style: TextStyle(color: AppColors.primaryStatusNeg)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmExpense(expense),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryStatusPos,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Confirmar ($_countdown)'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.5, curve: Curves.easeOutQuart, duration: 600.ms).fadeIn();
  }

  String _statusLabel(VoiceInputStateStatus status) {
    switch (status) {
      case VoiceInputStateStatus.requestingPermission:
        return 'Solicitando permissão...';
      case VoiceInputStateStatus.listening:
        return 'Ouvindo...';
      case VoiceInputStateStatus.processing:
        return 'Processando...';
      case VoiceInputStateStatus.confirming:
        return 'Confirme o registro';
      case VoiceInputStateStatus.error:
        return 'Ocorreu um erro';
      default:
        return 'Entrada por voz';
    }
  }

  Widget _buildStatusText(VoiceInputState state) {
    final theme = Theme.of(context);
    final text = state.currentText.isEmpty &&
            state.status == VoiceInputStateStatus.listening
        ? 'Fale algo como "Gastei 50 reais de gasolina"'
        : state.currentText;

    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyLarge.copyWith(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
        height: 1.5,
        fontWeight: FontWeight.w300,
        fontSize: 20,
      ),
    );
  }
}
