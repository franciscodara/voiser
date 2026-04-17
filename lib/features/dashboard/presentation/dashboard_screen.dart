import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/features/dashboard/domain/monthly_summary.dart';
import 'package:finwise/features/dashboard/presentation/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Dashboard', style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
            onPressed: () => ref.read(dashboardNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Seletor de Mês ──────────────────────────────────
                  _MonthSelector(
                    month: state.selectedMonth,
                    year: state.selectedYear,
                    onPrevious: () {
                      final d = DateTime(state.selectedYear, state.selectedMonth - 1);
                      ref.read(dashboardNotifierProvider.notifier).selectMonth(d.month, d.year);
                    },
                    onNext: () {
                      final next = DateTime(state.selectedYear, state.selectedMonth + 1);
                      if (next.isBefore(DateTime.now().add(const Duration(days: 31)))) {
                        ref.read(dashboardNotifierProvider.notifier).selectMonth(next.month, next.year);
                      }
                    },
                  ).animate().fade(duration: 300.ms),

                  const SizedBox(height: 20),

                  // ── Loading ──────────────────────────────────────────
                  if (state.isLoading)
                    const _LoadingSection()

                  // ── Erro ─────────────────────────────────────────────
                  else if (state.errorMessage != null)
                    _ErrorSection(message: state.errorMessage!)

                  // ── Dados ─────────────────────────────────────────────
                  else if (state.summary != null) ...[
                    _BalanceCards(summary: state.summary!)
                        .animate()
                        .fade(delay: 100.ms, duration: 400.ms)
                        .slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    if (state.summary!.byCategory.isNotEmpty) ...[
                      _SectionTitle(title: 'Gastos por Categoria'),
                      const SizedBox(height: 16),
                      _PieChartCard(summary: state.summary!)
                          .animate()
                          .fade(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      _SectionTitle(title: 'Top Categorias'),
                      const SizedBox(height: 16),
                      _BarChartCard(summary: state.summary!)
                          .animate()
                          .fade(delay: 300.ms, duration: 400.ms)
                          .slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      _SectionTitle(title: 'Detalhes'),
                      const SizedBox(height: 12),
                      _CategoryListCard(summary: state.summary!)
                          .animate()
                          .fade(delay: 400.ms, duration: 400.ms),
                    ] else
                      _EmptyMonthState(month: state.selectedMonth, year: state.selectedYear)
                          .animate()
                          .fade(delay: 200.ms, duration: 400.ms),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Seletor de Mês ──────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final int month;
  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.year,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat("MMMM 'de' yyyy", 'pt_BR')
        .format(DateTime(year, month))
        .toLowerCase();
    final isCurrentMonth =
        month == DateTime.now().month && year == DateTime.now().year;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrevious,
            tooltip: 'Mês anterior',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isCurrentMonth)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryStatusPos.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Mês atual',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryStatusPos,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: isCurrentMonth
                  ? theme.disabledColor
                  : theme.colorScheme.onSurface,
            ),
            onPressed: isCurrentMonth ? null : onNext,
            tooltip: 'Próximo mês',
          ),
        ],
      ),
    );
  }
}

// ─── Cards de saldo ──────────────────────────────────────────────────────────

class _BalanceCards extends StatelessWidget {
  final MonthlySummary summary;
  const _BalanceCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Column(
      children: [
        // Saldo principal
        _GlassCard(
          gradient: LinearGradient(
            colors: summary.isPositive
                ? [const Color(0xFF1B5E20), const Color(0xFF388E3C)]
                : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    summary.isPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saldo do mês',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                fmt.format(summary.balance),
                style: AppTextStyles.headline.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Entradas / Saídas
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.south_west_rounded,
                iconColor: AppColors.primaryStatusNeg,
                label: 'Saídas',
                value: fmt.format(summary.totalExpenses),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.north_east_rounded,
                iconColor: AppColors.primaryStatusPos,
                label: 'Entradas',
                value: fmt.format(summary.totalIncome),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Gradient gradient;
  final Widget child;
  const _GlassCard({required this.gradient, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SmallMetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color)),
                Text(value,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gráfico Pizza ───────────────────────────────────────────────────────────

class _PieChartCard extends StatefulWidget {
  final MonthlySummary summary;
  const _PieChartCard({required this.summary});

  @override
  State<_PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<_PieChartCard> {
  int _touchedIndex = -1;

  // Colors no longer hardcoded as we use cat.color
  Color _colorFor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byCategory = widget.summary.byCategory;
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final topCategories = byCategory.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                      } else {
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      }
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 44,
                sections: topCategories.asMap().entries.map((entry) {
                  final i = entry.key;
                  final cat = entry.value;
                  final isTouched = i == _touchedIndex;
                  final pct = cat.percentage;
                  final color = _colorFor(cat.color);

                  return PieChartSectionData(
                    color: color,
                    value: cat.total,
                    title: isTouched
                        ? '${pct.toStringAsFixed(1)}%'
                        : (pct > 8 ? '${pct.toStringAsFixed(0)}%' : ''),
                    radius: isTouched ? 72 : 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    badgeWidget: isTouched
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              fmt.format(cat.total),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : null,
                    badgePositionPercentageOffset: 1.4,
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legenda
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: topCategories.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _colorFor(cat.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cat.categoryName,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Gráfico de Barras ───────────────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  final MonthlySummary summary;
  const _BarChartCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top5 = summary.byCategory.take(5).toList();
    if (top5.isEmpty) return const SizedBox.shrink();

    final maxVal = top5.first.total;
    final fmt = NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$');

    Color _colorFor(String hexString) {
      try {
        final buffer = StringBuffer();
        if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (_) {
        return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal * 1.25,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${top5[groupIndex].categoryName}\n',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: fmt.format(rod.toY),
                        style: TextStyle(
                          color: AppColors.primaryStatusNeg,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i >= top5.length) return const SizedBox.shrink();
                    final name = top5[i].categoryName;
                    final short = name.length > 8 ? name.substring(0, 8) : name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        short,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.dividerColor.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            barGroups: top5.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.total,
                    color: _colorFor(entry.value.color),
                    width: 24,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal * 1.25,
                      color: theme.dividerColor.withOpacity(0.08),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Lista por categoria ─────────────────────────────────────────────────────

class _CategoryListCard extends StatelessWidget {
  final MonthlySummary summary;
  const _CategoryListCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        children: summary.byCategory.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          final pct = cat.percentage;
          
          Color _colorFor(String hexString) {
            try {
              final buffer = StringBuffer();
              if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
              buffer.write(hexString.replaceFirst('#', ''));
              return Color(int.parse(buffer.toString(), radix: 16));
            } catch (_) {
              return Colors.grey;
            }
          }
          final color = _colorFor(cat.color);

          return Column(
            children: [
              if (i > 0)
                Divider(
                    height: 1,
                    color: theme.dividerColor.withOpacity(0.15)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(cat.categoryName,
                              style: AppTextStyles.bodyMedium),
                        ),
                        Text(
                          '${cat.count} item${cat.count > 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          fmt.format(cat.total),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: color.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Empty / Loading / Error ──────────────────────────────────────────────────

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando dados da planilha...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  const _ErrorSection({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryStatusNeg.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryStatusNeg.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.primaryStatusNeg),
          const SizedBox(height: 12),
          Text('Erro ao carregar',
              style: AppTextStyles.title
                  .copyWith(color: AppColors.primaryStatusNeg)),
          const SizedBox(height: 4),
          Text(
            message,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyMonthState extends StatelessWidget {
  final int month;
  final int year;
  const _EmptyMonthState({required this.month, required this.year});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat("MMMM 'de' yyyy", 'pt_BR')
        .format(DateTime(year, month))
        .toLowerCase();
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 56,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Sem dados em $label',
            style: AppTextStyles.title.copyWith(
                color: theme.textTheme.bodySmall?.color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Registre despesas para visualizar o resumo aqui.',
            style: AppTextStyles.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(
        color: Theme.of(context).textTheme.bodySmall?.color,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
