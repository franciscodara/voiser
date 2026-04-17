// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  return _Expense.fromJson(json);
}

/// @nodoc
mixin _$Expense {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  EntryOrigin get origin => throw _privateConstructorUsedError;

  /// true = sincronizado com Sheets; false = pendente
  bool get synced => throw _privateConstructorUsedError;

  /// true = excluído logicamente offline; false = ativo
  bool get deleted => throw _privateConstructorUsedError;

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCopyWith<Expense> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCopyWith<$Res> {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) then) =
      _$ExpenseCopyWithImpl<$Res, Expense>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String categoryId,
      String categoryName,
      String? subcategory,
      String? description,
      double amount,
      TransactionType type,
      EntryOrigin origin,
      bool synced,
      bool deleted});
}

/// @nodoc
class _$ExpenseCopyWithImpl<$Res, $Val extends Expense>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? subcategory = freezed,
    Object? description = freezed,
    Object? amount = null,
    Object? type = null,
    Object? origin = null,
    Object? synced = null,
    Object? deleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      subcategory: freezed == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as EntryOrigin,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
      deleted: null == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseImplCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$$ExpenseImplCopyWith(
          _$ExpenseImpl value, $Res Function(_$ExpenseImpl) then) =
      __$$ExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String categoryId,
      String categoryName,
      String? subcategory,
      String? description,
      double amount,
      TransactionType type,
      EntryOrigin origin,
      bool synced,
      bool deleted});
}

/// @nodoc
class __$$ExpenseImplCopyWithImpl<$Res>
    extends _$ExpenseCopyWithImpl<$Res, _$ExpenseImpl>
    implements _$$ExpenseImplCopyWith<$Res> {
  __$$ExpenseImplCopyWithImpl(
      _$ExpenseImpl _value, $Res Function(_$ExpenseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? subcategory = freezed,
    Object? description = freezed,
    Object? amount = null,
    Object? type = null,
    Object? origin = null,
    Object? synced = null,
    Object? deleted = null,
  }) {
    return _then(_$ExpenseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      subcategory: freezed == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as EntryOrigin,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
      deleted: null == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseImpl implements _Expense {
  const _$ExpenseImpl(
      {required this.id,
      required this.date,
      required this.categoryId,
      required this.categoryName,
      this.subcategory,
      this.description,
      required this.amount,
      this.type = TransactionType.expense,
      this.origin = EntryOrigin.manual,
      this.synced = false,
      this.deleted = false});

  factory _$ExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String categoryId;
  @override
  final String categoryName;
  @override
  final String? subcategory;
  @override
  final String? description;
  @override
  final double amount;
  @override
  @JsonKey()
  final TransactionType type;
  @override
  @JsonKey()
  final EntryOrigin origin;

  /// true = sincronizado com Sheets; false = pendente
  @override
  @JsonKey()
  final bool synced;

  /// true = excluído logicamente offline; false = ativo
  @override
  @JsonKey()
  final bool deleted;

  @override
  String toString() {
    return 'Expense(id: $id, date: $date, categoryId: $categoryId, categoryName: $categoryName, subcategory: $subcategory, description: $description, amount: $amount, type: $type, origin: $origin, synced: $synced, deleted: $deleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.origin, origin) || other.origin == origin) &&
            (identical(other.synced, synced) || other.synced == synced) &&
            (identical(other.deleted, deleted) || other.deleted == deleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
      categoryId,
      categoryName,
      subcategory,
      description,
      amount,
      type,
      origin,
      synced,
      deleted);

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      __$$ExpenseImplCopyWithImpl<_$ExpenseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseImplToJson(
      this,
    );
  }
}

abstract class _Expense implements Expense {
  const factory _Expense(
      {required final String id,
      required final DateTime date,
      required final String categoryId,
      required final String categoryName,
      final String? subcategory,
      final String? description,
      required final double amount,
      final TransactionType type,
      final EntryOrigin origin,
      final bool synced,
      final bool deleted}) = _$ExpenseImpl;

  factory _Expense.fromJson(Map<String, dynamic> json) = _$ExpenseImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get categoryId;
  @override
  String get categoryName;
  @override
  String? get subcategory;
  @override
  String? get description;
  @override
  double get amount;
  @override
  TransactionType get type;
  @override
  EntryOrigin get origin;

  /// true = sincronizado com Sheets; false = pendente
  @override
  bool get synced;

  /// true = excluído logicamente offline; false = ativo
  @override
  bool get deleted;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
