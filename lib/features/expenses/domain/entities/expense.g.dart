// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']) ??
          TransactionType.expense,
      origin: $enumDecodeNullable(_$EntryOriginEnumMap, json['origin']) ??
          EntryOrigin.manual,
      synced: json['synced'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'subcategory': instance.subcategory,
      'description': instance.description,
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'origin': _$EntryOriginEnumMap[instance.origin]!,
      'synced': instance.synced,
      'deleted': instance.deleted,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

const _$EntryOriginEnumMap = {
  EntryOrigin.manual: 'manual',
  EntryOrigin.voice: 'voice',
};
