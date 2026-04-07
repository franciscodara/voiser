// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categorySubcategoriesHash() =>
    r'b04d9991224e719d87de66f5c5b5d58602d23ca0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider das categorias — expõe a lista estática de DefaultCategories.
/// Separado aqui para facilitar mock em testes.
///
/// Copied from [categorySubcategories].
@ProviderFor(categorySubcategories)
const categorySubcategoriesProvider = CategorySubcategoriesFamily();

/// Provider das categorias — expõe a lista estática de DefaultCategories.
/// Separado aqui para facilitar mock em testes.
///
/// Copied from [categorySubcategories].
class CategorySubcategoriesFamily extends Family<List<String>> {
  /// Provider das categorias — expõe a lista estática de DefaultCategories.
  /// Separado aqui para facilitar mock em testes.
  ///
  /// Copied from [categorySubcategories].
  const CategorySubcategoriesFamily();

  /// Provider das categorias — expõe a lista estática de DefaultCategories.
  /// Separado aqui para facilitar mock em testes.
  ///
  /// Copied from [categorySubcategories].
  CategorySubcategoriesProvider call(
    String categoryId,
  ) {
    return CategorySubcategoriesProvider(
      categoryId,
    );
  }

  @override
  CategorySubcategoriesProvider getProviderOverride(
    covariant CategorySubcategoriesProvider provider,
  ) {
    return call(
      provider.categoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categorySubcategoriesProvider';
}

/// Provider das categorias — expõe a lista estática de DefaultCategories.
/// Separado aqui para facilitar mock em testes.
///
/// Copied from [categorySubcategories].
class CategorySubcategoriesProvider extends AutoDisposeProvider<List<String>> {
  /// Provider das categorias — expõe a lista estática de DefaultCategories.
  /// Separado aqui para facilitar mock em testes.
  ///
  /// Copied from [categorySubcategories].
  CategorySubcategoriesProvider(
    String categoryId,
  ) : this._internal(
          (ref) => categorySubcategories(
            ref as CategorySubcategoriesRef,
            categoryId,
          ),
          from: categorySubcategoriesProvider,
          name: r'categorySubcategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categorySubcategoriesHash,
          dependencies: CategorySubcategoriesFamily._dependencies,
          allTransitiveDependencies:
              CategorySubcategoriesFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategorySubcategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    List<String> Function(CategorySubcategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategorySubcategoriesProvider._internal(
        (ref) => create(ref as CategorySubcategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<String>> createElement() {
    return _CategorySubcategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategorySubcategoriesProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategorySubcategoriesRef on AutoDisposeProviderRef<List<String>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CategorySubcategoriesProviderElement
    extends AutoDisposeProviderElement<List<String>>
    with CategorySubcategoriesRef {
  _CategorySubcategoriesProviderElement(super.provider);

  @override
  String get categoryId => (origin as CategorySubcategoriesProvider).categoryId;
}

String _$expenseNotifierHash() => r'bad89a3d42a9125e29cae311086af74aca2adb9f';

/// Provider da lista de despesas do mês corrente.
///
/// Copied from [ExpenseNotifier].
@ProviderFor(ExpenseNotifier)
final expenseNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ExpenseNotifier, List<Expense>>.internal(
  ExpenseNotifier.new,
  name: r'expenseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseNotifier = AutoDisposeAsyncNotifier<List<Expense>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
