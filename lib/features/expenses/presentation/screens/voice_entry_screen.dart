import 'dart:async';
import 'dart:math';

import 'package:finwise/core/constants/default_categories.dart';
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

  void _confirmExpense(Expense expense) {
    if (!mounted) return;

    ref.read(voiceInputNotifierProvider.notifier).confirm();
    ref.read(expenseNotifierProvider.notifier).addExpense(expense);
    _countdownTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          expense.type == TransactionType.income
              ? 'Receita salva com sucesso!'
              : 'Despesa inteligente salva voando!',
        ),
        backgroundColor: Colors.green.shade600,
      ),
    );
    context.pop();
  }

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
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            ref.read(voiceInputNotifierProvider.notifier).cancel();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildCenterArea(state),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.currentText.isEmpty && state.status == VoiceInputStateStatus.listening
                    ? 'Fale algo como "Gastei 50 reais de gasolina"'
                    : state.currentText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const Spacer(),
            if (state.status == VoiceInputStateStatus.confirming && state.result != null)
              _buildConfirmationCard(state)
            else if (state.status == VoiceInputStateStatus.error)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Erro desconhecido.',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
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
              backgroundColor: Colors.white24,
              elevation: 0,
              label: const Text('Parar agora', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCenterArea(VoiceInputState state) {
    if (state.status == VoiceInputStateStatus.processing) {
      return Center(
        child: const CircularProgressIndicator(color: Colors.purpleAccent)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(end: 1.2),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: state.status == VoiceInputStateStatus.listening
              ? Colors.purple.withOpacity(0.2)
              : Colors.white10,
        ),
        child: Icon(
          Icons.mic_none_outlined,
          size: 80,
          color: state.status == VoiceInputStateStatus.listening
              ? Colors.purpleAccent
              : Colors.white54,
        ),
      )
          .animate(target: state.status == VoiceInputStateStatus.listening ? 1 : 0)
          .scaleXY(end: 1.15, duration: 1000.ms, curve: Curves.easeInOutSine)
          .tint(color: Colors.purple.shade200),
    );
  }

  Widget _buildConfirmationCard(VoiceInputState state) {
    final result = state.result!;
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
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
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: Colors.purple.shade400),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'R\$ ${result.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${result.category}${result.subcategory != null ? ' • ${result.subcategory}' : ''}',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade500),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            result.type == 'income' ? 'Receita detectada por voz' : 'Despesa detectada por voz',
            style: TextStyle(
              color: Colors.grey.shade600,
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
                  child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmExpense(expense),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
