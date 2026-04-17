// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CategoryTotal {
  String get categoryName => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;

  /// Create a copy of CategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryTotalCopyWith<CategoryTotal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryTotalCopyWith<$Res> {
  factory $CategoryTotalCopyWith(
          CategoryTotal value, $Res Function(CategoryTotal) then) =
      _$CategoryTotalCopyWithImpl<$Res, CategoryTotal>;
  @useResult
  $Res call(
      {String categoryName,
      double total,
      int count,
      double percentage,
      String color});
}

/// @nodoc
class _$CategoryTotalCopyWithImpl<$Res, $Val extends CategoryTotal>
    implements $CategoryTotalCopyWith<$Res> {
  _$CategoryTotalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? total = null,
    Object? count = null,
    Object? percentage = null,
    Object? color = null,
  }) {
    return _then(_value.copyWith(
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryTotalImplCopyWith<$Res>
    implements $CategoryTotalCopyWith<$Res> {
  factory _$$CategoryTotalImplCopyWith(
          _$CategoryTotalImpl value, $Res Function(_$CategoryTotalImpl) then) =
      __$$CategoryTotalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String categoryName,
      double total,
      int count,
      double percentage,
      String color});
}

/// @nodoc
class __$$CategoryTotalImplCopyWithImpl<$Res>
    extends _$CategoryTotalCopyWithImpl<$Res, _$CategoryTotalImpl>
    implements _$$CategoryTotalImplCopyWith<$Res> {
  __$$CategoryTotalImplCopyWithImpl(
      _$CategoryTotalImpl _value, $Res Function(_$CategoryTotalImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? total = null,
    Object? count = null,
    Object? percentage = null,
    Object? color = null,
  }) {
    return _then(_$CategoryTotalImpl(
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CategoryTotalImpl implements _CategoryTotal {
  const _$CategoryTotalImpl(
      {required this.categoryName,
      required this.total,
      required this.count,
      this.percentage = 0.0,
      this.color = '#000000'});

  @override
  final String categoryName;
  @override
  final double total;
  @override
  final int count;
  @override
  @JsonKey()
  final double percentage;
  @override
  @JsonKey()
  final String color;

  @override
  String toString() {
    return 'CategoryTotal(categoryName: $categoryName, total: $total, count: $count, percentage: $percentage, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryTotalImpl &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.color, color) || other.color == color));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, categoryName, total, count, percentage, color);

  /// Create a copy of CategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryTotalImplCopyWith<_$CategoryTotalImpl> get copyWith =>
      __$$CategoryTotalImplCopyWithImpl<_$CategoryTotalImpl>(this, _$identity);
}

abstract class _CategoryTotal implements CategoryTotal {
  const factory _CategoryTotal(
      {required final String categoryName,
      required final double total,
      required final int count,
      final double percentage,
      final String color}) = _$CategoryTotalImpl;

  @override
  String get categoryName;
  @override
  double get total;
  @override
  int get count;
  @override
  double get percentage;
  @override
  String get color;

  /// Create a copy of CategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryTotalImplCopyWith<_$CategoryTotalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MonthlySummary {
  int get month => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  double get totalExpenses => throw _privateConstructorUsedError;
  double get totalIncome => throw _privateConstructorUsedError;
  List<CategoryTotal> get byCategory => throw _privateConstructorUsedError;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlySummaryCopyWith<MonthlySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlySummaryCopyWith<$Res> {
  factory $MonthlySummaryCopyWith(
          MonthlySummary value, $Res Function(MonthlySummary) then) =
      _$MonthlySummaryCopyWithImpl<$Res, MonthlySummary>;
  @useResult
  $Res call(
      {int month,
      int year,
      double totalExpenses,
      double totalIncome,
      List<CategoryTotal> byCategory});
}

/// @nodoc
class _$MonthlySummaryCopyWithImpl<$Res, $Val extends MonthlySummary>
    implements $MonthlySummaryCopyWith<$Res> {
  _$MonthlySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
    Object? totalExpenses = null,
    Object? totalIncome = null,
    Object? byCategory = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      totalExpenses: null == totalExpenses
          ? _value.totalExpenses
          : totalExpenses // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      byCategory: null == byCategory
          ? _value.byCategory
          : byCategory // ignore: cast_nullable_to_non_nullable
              as List<CategoryTotal>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlySummaryImplCopyWith<$Res>
    implements $MonthlySummaryCopyWith<$Res> {
  factory _$$MonthlySummaryImplCopyWith(_$MonthlySummaryImpl value,
          $Res Function(_$MonthlySummaryImpl) then) =
      __$$MonthlySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int month,
      int year,
      double totalExpenses,
      double totalIncome,
      List<CategoryTotal> byCategory});
}

/// @nodoc
class __$$MonthlySummaryImplCopyWithImpl<$Res>
    extends _$MonthlySummaryCopyWithImpl<$Res, _$MonthlySummaryImpl>
    implements _$$MonthlySummaryImplCopyWith<$Res> {
  __$$MonthlySummaryImplCopyWithImpl(
      _$MonthlySummaryImpl _value, $Res Function(_$MonthlySummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
    Object? totalExpenses = null,
    Object? totalIncome = null,
    Object? byCategory = null,
  }) {
    return _then(_$MonthlySummaryImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      totalExpenses: null == totalExpenses
          ? _value.totalExpenses
          : totalExpenses // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      byCategory: null == byCategory
          ? _value._byCategory
          : byCategory // ignore: cast_nullable_to_non_nullable
              as List<CategoryTotal>,
    ));
  }
}

/// @nodoc

class _$MonthlySummaryImpl extends _MonthlySummary {
  const _$MonthlySummaryImpl(
      {required this.month,
      required this.year,
      required this.totalExpenses,
      required this.totalIncome,
      required final List<CategoryTotal> byCategory})
      : _byCategory = byCategory,
        super._();

  @override
  final int month;
  @override
  final int year;
  @override
  final double totalExpenses;
  @override
  final double totalIncome;
  final List<CategoryTotal> _byCategory;
  @override
  List<CategoryTotal> get byCategory {
    if (_byCategory is EqualUnmodifiableListView) return _byCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_byCategory);
  }

  @override
  String toString() {
    return 'MonthlySummary(month: $month, year: $year, totalExpenses: $totalExpenses, totalIncome: $totalIncome, byCategory: $byCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlySummaryImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.totalExpenses, totalExpenses) ||
                other.totalExpenses == totalExpenses) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            const DeepCollectionEquality()
                .equals(other._byCategory, _byCategory));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month, year, totalExpenses,
      totalIncome, const DeepCollectionEquality().hash(_byCategory));

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      __$$MonthlySummaryImplCopyWithImpl<_$MonthlySummaryImpl>(
          this, _$identity);
}

abstract class _MonthlySummary extends MonthlySummary {
  const factory _MonthlySummary(
      {required final int month,
      required final int year,
      required final double totalExpenses,
      required final double totalIncome,
      required final List<CategoryTotal> byCategory}) = _$MonthlySummaryImpl;
  const _MonthlySummary._() : super._();

  @override
  int get month;
  @override
  int get year;
  @override
  double get totalExpenses;
  @override
  double get totalIncome;
  @override
  List<CategoryTotal> get byCategory;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
