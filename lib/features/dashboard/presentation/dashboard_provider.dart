import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/dashboard/data/local_report_datasource.dart';
import 'package:finwise/features/dashboard/domain/monthly_summary.dart';

part 'dashboard_provider.g.dart';

/// Estado do Dashboard
class DashboardState {
  final int selectedMonth;
  final int selectedYear;
  final MonthlySummary? summary;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    required this.selectedMonth,
    required this.selectedYear,
    this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    int? selectedMonth,
    int? selectedYear,
    MonthlySummary? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class DashboardNotifier extends _$DashboardNotifier {

  @override
  DashboardState build() {
    final now = DateTime.now();
    // Carrega automaticamente ao montar
    Future.microtask(() => _load(now.month, now.year));
    return DashboardState(
      selectedMonth: now.month,
      selectedYear: now.year,
      isLoading: true,
    );
  }

  /// Muda o mês selecionado e recarrega os dados
  Future<void> selectMonth(int month, int year) async {
    state = state.copyWith(
      selectedMonth: month,
      selectedYear: year,
      isLoading: true,
      errorMessage: null,
    );
    await _load(month, year);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _load(state.selectedMonth, state.selectedYear);
  }

  Future<void> _load(int month, int year) async {
    try {
      final datasource = ref.read(localReportDatasourceProvider);
      final summary = await datasource.getMonthlySummary(
        month: month,
        year: year,
      );

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('❌ DashboardNotifier error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados: $e',
      );
    }
  }


}
