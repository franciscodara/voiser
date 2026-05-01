// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
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
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
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
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

const _$EntryOriginEnumMap = {
  EntryOrigin.manual: 'manual',
  EntryOrigin.voice: 'voice',
};
