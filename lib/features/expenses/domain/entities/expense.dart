import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

/// Tipo da transação registrada
enum TransactionType { expense, income }

/// Origem do registro
enum EntryOrigin { manual, voice }

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required DateTime date,
    required String categoryId,
    required String categoryName,
    String? subcategory,
    String? description,
    required double amount,
    @Default(TransactionType.expense) TransactionType type,
    @Default(EntryOrigin.manual) EntryOrigin origin,
    /// true = sincronizado com Sheets; false = pendente
    @Default(false) bool synced,
    /// true = excluído logicamente offline; false = ativo
    @Default(false) bool deleted,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
