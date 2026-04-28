import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Retângulo animado com efeito shimmer para skeleton loading.
/// Não requer dependência adicional — usa flutter_animate já instalado.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlightColor,
          angle: 0.3,
        );
  }
}

/// Skeleton completo de um card de transação (para listas).
class ExpenseCardSkeleton extends StatelessWidget {
  const ExpenseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          // Ícone
          const ShimmerBox(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: 13),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(height: 13, borderRadius: 6),
                SizedBox(height: 6),
                ShimmerBox(width: 120, height: 10, borderRadius: 5),
                SizedBox(height: 6),
                ShimmerBox(width: 80, height: 9, borderRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Valor
          const ShimmerBox(width: 70, height: 16, borderRadius: 6),
        ],
      ),
    );
  }
}

/// Skeleton do card de resumo mensal (HomeScreen).
class SummaryCardSkeleton extends StatelessWidget {
  const SummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBox(width: 120, height: 12, borderRadius: 6),
          SizedBox(height: 16),
          ShimmerBox(width: 200, height: 36, borderRadius: 8),
          SizedBox(height: 8),
          ShimmerBox(width: 160, height: 11, borderRadius: 5),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 36, borderRadius: 8)),
              SizedBox(width: 24),
              Expanded(child: ShimmerBox(height: 36, borderRadius: 8)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton do Dashboard (card de saldo + cards menores).
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card principal de saldo
        const ShimmerBox(height: 110, borderRadius: 20),
        const SizedBox(height: 12),
        // Cards de entradas/saídas
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 70, borderRadius: 16)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 70, borderRadius: 16)),
          ],
        ),
        const SizedBox(height: 28),
        // Título de seção
        const ShimmerBox(width: 160, height: 14, borderRadius: 7),
        const SizedBox(height: 16),
        // Gráfico placeholder
        const ShimmerBox(height: 200, borderRadius: 20),
        const SizedBox(height: 24),
        // Barras de categoria
        const ShimmerBox(width: 140, height: 14, borderRadius: 7),
        const SizedBox(height: 16),
        for (int i = 0; i < 4; i++) ...[
          _CategoryRowSkeleton(width: _widths[i]),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  static const _widths = [1.0, 0.75, 0.55, 0.4];
}

class _CategoryRowSkeleton extends StatelessWidget {
  final double width;
  const _CategoryRowSkeleton({required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ShimmerBox(width: 10, height: 10, borderRadius: 5),
        const SizedBox(width: 10),
        Expanded(
          flex: (width * 10).toInt(),
          child: const ShimmerBox(height: 10, borderRadius: 5),
        ),
        Expanded(
          flex: ((1 - width) * 10).toInt() + 1,
          child: const SizedBox(),
        ),
        const SizedBox(width: 8),
        const ShimmerBox(width: 60, height: 10, borderRadius: 5),
      ],
    );
  }
}
