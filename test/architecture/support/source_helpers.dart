import 'project.dart';

/// Source text of [path] with whole-line `//` comments blanked out (line
/// numbers are preserved).
String codeText(ProjectRoot root, String path) =>
    root.lines(path).map((l) => l.isComment ? '' : l.text).join('\n');

/// 1-based line number of [offset] in [text].
int lineOf(String text, int offset) =>
    '\n'.allMatches(text.substring(0, offset)).length + 1;

String lowerFirst(String s) =>
    s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

/// File name without directory.
String baseName(String path) => path.split('/').last;

/// File name without directory and `.dart`.
String stem(String path) {
  final name = baseName(path);
  return name.endsWith('.dart') ? name.substring(0, name.length - 5) : name;
}

/// Index of the bracket closing the one at [openIndex] (-1 if unbalanced).
int matchingClose(String text, int openIndex) {
  const pairs = {'(': ')', '{': '}', '[': ']', '<': '>'};
  final open = text[openIndex];
  final close = pairs[open]!;
  var depth = 0;
  for (var i = openIndex; i < text.length; i++) {
    if (text[i] == open) depth++;
    if (text[i] == close) {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

/// A top-level declaration: class, enum, mixin or extension.
class TypeDecl {
  const TypeDecl(this.name, this.kind, this.line, [this.onType]);

  final String name;

  /// `class`, `enum`, `mixin` or `extension`.
  final String kind;
  final int line;

  /// Extended type of an extension.
  final String? onType;
}

final _typeRegex = RegExp(
  r'^(?:(?:abstract|sealed|final|base|interface)\s+)*(class|enum|mixin)\s+(\w+)',
  multiLine: true,
);
final _extensionRegex = RegExp(
  r'^extension\s+(\w+)\s+on\s+(\w+)',
  multiLine: true,
);

/// Top-level class/enum/mixin/extension declarations (column 0) of [text].
List<TypeDecl> declaredTypes(String text) {
  final result = <TypeDecl>[
    for (final m in _typeRegex.allMatches(text))
      TypeDecl(m.group(2)!, m.group(1)!, lineOf(text, m.start)),
    for (final m in _extensionRegex.allMatches(text))
      if (m.group(1) != 'on')
        TypeDecl(
          m.group(1)!,
          'extension',
          lineOf(text, m.start),
          m.group(2)!,
        ),
  ];
  result.sort((a, b) => a.line.compareTo(b.line));
  return result;
}

/// An extension with its block body.
class ExtensionDecl {
  const ExtensionDecl(this.name, this.onType, this.body, this.line);

  final String name;
  final String onType;
  final String body;
  final int line;
}

List<ExtensionDecl> extensionDecls(String text) {
  final result = <ExtensionDecl>[];
  for (final m in _extensionRegex.allMatches(text)) {
    if (m.group(1) == 'on') continue;
    final open = text.indexOf('{', m.end);
    if (open < 0) continue;
    final close = matchingClose(text, open);
    if (close < 0) continue;
    result.add(
      ExtensionDecl(
        m.group(1)!,
        m.group(2)!,
        text.substring(open + 1, close),
        lineOf(text, m.start),
      ),
    );
  }
  return result;
}

/// A constructor parameter: `String? region` -> type `String?`, name `region`.
class Param {
  const Param(this.type, this.name);

  final String type;
  final String name;
}

List<String> _splitTopLevel(String s) {
  final parts = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if ('<([{'.contains(c)) depth++;
    if ('>)]}'.contains(c)) depth--;
    if (c == ',' && depth == 0) {
      parts.add(s.substring(start, i));
      start = i + 1;
    }
  }
  parts.add(s.substring(start));
  return parts.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
}

Param _parseParam(String source) {
  var t = source.trim();
  while (t.startsWith('@')) {
    final m = RegExp(r'^@\w+').firstMatch(t)!;
    var end = m.end;
    if (end < t.length && t[end] == '(') end = matchingClose(t, end) + 1;
    t = t.substring(end).trim();
  }
  t = t.replaceFirst(RegExp(r'^required\s+'), '');
  final eq = t.indexOf('=');
  if (eq >= 0) t = t.substring(0, eq).trim();
  if (t.startsWith('this.')) return Param('', t.substring(5));
  final space = t.lastIndexOf(RegExp(r'\s'));
  if (space < 0) return Param('', t);
  return Param(t.substring(0, space).trim(), t.substring(space + 1));
}

/// Parameters of `const factory <name>(...)` in [text] (null if absent).
List<Param>? factoryParams(String text, String name) {
  final m = RegExp(
    r'const\s+factory\s+' + RegExp.escape(name) + r'\s*\(',
  ).firstMatch(text);
  if (m == null) return null;
  final open = m.end - 1;
  final close = matchingClose(text, open);
  if (close < 0) return null;
  var inner = text.substring(open + 1, close).trim();
  if (inner.startsWith('{')) {
    final end = inner.lastIndexOf('}');
    inner = inner.substring(1, end < 0 ? inner.length : end);
  }
  return _splitTopLevel(inner).map(_parseParam).toList();
}

/// `part '...';` directives of [path] (comments skipped).
List<({int line, String uri})> partDirectives(ProjectRoot root, String path) {
  final regex = RegExp(r'''^\s*part\s+['"]([^'"]+)['"]\s*;''');
  return [
    for (final l in root.lines(path))
      if (!l.isComment && regex.hasMatch(l.text))
        (line: l.number, uri: regex.firstMatch(l.text)!.group(1)!),
  ];
}

/// Everything the content checks need to know about one feature.
class FeatureContext {
  FeatureContext(this.root, this.feature, this.entity, this.plural);

  final ProjectRoot root;
  final Feature feature;

  /// Snake-case entity name (the feature name for local features).
  final String entity;

  /// Snake-case plural, from the feature's `*_screen.dart` (API only; null
  /// when there is no screen).
  final String? plural;

  bool get isApi => feature.kind == FeatureKind.api;
  String get name => feature.name;
  String get entityPascal => snakeToPascal(entity);
  String get entityCamel => snakeToCamel(entity);
  String? get pluralPascal => plural == null ? null : snakeToPascal(plural!);
  String? get pluralCamel => plural == null ? null : snakeToCamel(plural!);

  String get entityPath => 'lib/domain/entities/$entity.dart';
  String get repositoryPath =>
      'lib/domain/repositories/$name/${entity}_repository.dart';
  String get useCaseDir => 'lib/domain/use_cases/$name';
  String get useCasePath => '$useCaseDir/${entity}_use_case.dart';
  String get modelDir => 'lib/data/models/$name';
  String get modelPath => '$modelDir/${entity}_model.dart';
  String get mapperPath => 'lib/data/mappers/${entity}_mapper.dart';
  String get datasourceDir => 'lib/data/datasource/$name';
  String get datasourcePath => '$datasourceDir/${entity}_datasource.dart';
  String get remotePath => '$datasourceDir/${entity}_datasource_remote.dart';
  String get repositoryImplPath =>
      'lib/data/repositories/$name/${entity}_repository_impl.dart';
  String get presentationDir =>
      isApi ? 'lib/presentation/features/$name' : 'lib/presentation/$name';
  String get statePath => '$presentationDir/${entity}_state.dart';
  String get viewmodelPath => '$presentationDir/${entity}_viewmodel.dart';

  List<String> _direct(String dir, [bool Function(String)? where]) => [
    for (final p in root.dartFilesIn(dir))
      if (!p.substring(dir.length + 1).contains('/') &&
          (where == null || where(p)))
        p,
  ];

  /// Direct `.dart` children of the feature's use case directory.
  List<String> get useCasePaths =>
      _direct(useCaseDir, (p) => p.endsWith('_use_case.dart'));

  /// Direct `.dart` children of `data/models/<feature>/`.
  List<String> get modelPaths => _direct(modelDir);

  /// `*_screen.dart` files in the feature's presentation directory.
  List<String> get screenPaths =>
      _direct(presentationDir, (p) => p.endsWith('_screen.dart'));

  /// `*_item_view.dart` files in `<presentation>/widget/`.
  List<String> get itemViewPaths => _direct(
    '$presentationDir/widget',
    (p) => p.endsWith('_item_view.dart'),
  );

  /// Existing feature files at their canonical paths (generated excluded).
  List<String> get featureFiles {
    final candidates = <String>[
      if (isApi) entityPath,
      repositoryPath,
      ...useCasePaths,
      if (isApi) ...[
        ...modelPaths,
        mapperPath,
        datasourcePath,
        remotePath,
        statePath,
        ...screenPaths,
        ...itemViewPaths,
      ],
      repositoryImplPath,
      viewmodelPath,
    ];
    return {
      for (final p in candidates)
        if (root.fileExists(p)) p,
    }.toList();
  }
}

/// Contexts for every feature of [root] that has an entity name.
List<FeatureContext> featureContexts(ProjectRoot root) {
  final result = <FeatureContext>[];
  for (final feature in discoverFeatures(root)) {
    final entity = entityName(root, feature);
    if (entity == null) continue;
    String? plural;
    if (feature.kind == FeatureKind.api) {
      final dir = 'lib/presentation/features/${feature.name}';
      for (final p in root.dartFilesIn(dir)) {
        if (p.substring(dir.length + 1).contains('/')) continue;
        if (p.endsWith('_screen.dart')) {
          final s = stem(p);
          plural = s.substring(0, s.length - '_screen'.length);
          break;
        }
      }
    }
    result.add(FeatureContext(root, feature, entity, plural));
  }
  return result;
}

// ---------------------------------------------------------------------------
// Sample code for fixture projects
// ---------------------------------------------------------------------------

/// Applies [from] -> [to] to every occurrence in [path] of a copy of [files].
/// Fails loudly if [from] is not found (so a mutation can never be a no-op).
Map<String, String> mutated(
  Map<String, String> files,
  String path,
  String from,
  String to,
) {
  final source = files[path];
  if (source == null) throw StateError('No file $path in fixture');
  if (!source.contains(from)) {
    throw StateError('"$from" not found in fixture file $path');
  }
  return {...files, path: source.replaceAll(from, to)};
}

/// Copy of [files] with [from] moved to [to].
Map<String, String> renamed(Map<String, String> files, String from, String to) {
  final source = files[from];
  if (source == null) throw StateError('No file $from in fixture');
  return {
    for (final e in files.entries)
      if (e.key != from) e.key: e.value,
    to: source,
  };
}

const sampleEntityPath = 'lib/domain/entities/product.dart';
const sampleRepositoryPath =
    'lib/domain/repositories/product/product_repository.dart';
const sampleUseCasePath = 'lib/domain/use_cases/product/product_use_case.dart';
const sampleModelPath = 'lib/data/models/product/product_model.dart';
const sampleNestedModelPath = 'lib/data/models/product/product_name_model.dart';
const sampleMapperPath = 'lib/data/mappers/product_mapper.dart';
const sampleDatasourcePath =
    'lib/data/datasource/product/product_datasource.dart';
const sampleRemotePath =
    'lib/data/datasource/product/product_datasource_remote.dart';
const sampleRepositoryImplPath =
    'lib/data/repositories/product/product_repository_impl.dart';
const sampleStatePath = 'lib/presentation/features/product/product_state.dart';
const sampleViewmodelPath =
    'lib/presentation/features/product/product_viewmodel.dart';
const sampleScreenPath =
    'lib/presentation/features/product/products_screen.dart';
const sampleItemViewPath =
    'lib/presentation/features/product/widget/product_item_view.dart';
const sampleDiProvidersPath = 'lib/presentation/providers/di_providers.dart';
const sampleApiEndpointPath = 'lib/data/datasource/core/api_endpoint.dart';
const sampleRoutesPath = 'lib/presentation/router/app_routes.dart';
const sampleThemeUseCasePath = 'lib/domain/use_cases/theme/theme_use_case.dart';
const sampleThemeRepositoryPath =
    'lib/domain/repositories/theme/theme_repository.dart';
const sampleThemeRepositoryImplPath =
    'lib/data/repositories/theme/theme_repository_impl.dart';
const sampleThemeViewmodelPath = 'lib/presentation/theme/theme_viewmodel.dart';

/// A minimal VALID project: API feature `product` (plural `products`, nested
/// `name`) plus local feature `theme`, plus the shared files. Every content
/// check must report nothing on it.
Map<String, String> sampleProject() => {
  sampleEntityPath: r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    String? region,
    ProductName? name,
  }) = _Product;
}

@freezed
abstract class ProductName with _$ProductName {
  const factory ProductName({
    String? common,
  }) = _ProductName;
}
''',
  sampleRepositoryPath: r'''
import 'package:sample_app/domain/core/result.dart';
import 'package:sample_app/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> fetchAllProducts();
}
''',
  sampleUseCasePath: r'''
import 'package:injectable/injectable.dart';
import 'package:sample_app/domain/core/result.dart';
import 'package:sample_app/domain/entities/product.dart';
import 'package:sample_app/domain/repositories/product/product_repository.dart';

@lazySingleton
class ProductUseCase {
  final ProductRepository repository;

  ProductUseCase(this.repository);

  Future<Result<List<Product>>> fetchAllProducts() async {
    return repository.fetchAllProducts();
  }
}
''',
  sampleModelPath: r'''
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sample_app/data/models/product/product_name_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    String? region,
    ProductNameModel? name,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}
''',
  sampleNestedModelPath: r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_name_model.freezed.dart';
part 'product_name_model.g.dart';

@freezed
abstract class ProductNameModel with _$ProductNameModel {
  const factory ProductNameModel({
    String? common,
  }) = _ProductNameModel;

  factory ProductNameModel.fromJson(Map<String, dynamic> json) => _$ProductNameModelFromJson(json);
}
''',
  sampleMapperPath: r'''
import 'package:sample_app/data/models/product/product_model.dart';
import 'package:sample_app/data/models/product/product_name_model.dart';
import 'package:sample_app/domain/entities/product.dart';

extension ProductModelMapper on ProductModel {
  Product toEntity() {
    return Product(
      region: region,
      name: name?.toEntity(),
    );
  }
}

extension ProductNameModelMapper on ProductNameModel {
  ProductName toEntity() {
    return ProductName(
      common: common,
    );
  }
}
''',
  sampleDatasourcePath: r'''
import 'package:sample_app/data/models/product/product_model.dart';
import 'package:sample_app/domain/core/result.dart';

abstract class ProductDatasource {
  Future<Result<List<ProductModel>>> fetchAllProducts();
}
''',
  sampleRemotePath: r'''
import 'package:injectable/injectable.dart';
import 'package:sample_app/data/datasource/core/api_client.dart';
import 'package:sample_app/data/datasource/core/api_endpoint.dart';
import 'package:sample_app/data/datasource/product/product_datasource.dart';
import 'package:sample_app/data/models/product/product_model.dart';
import 'package:sample_app/domain/core/result.dart';

@LazySingleton(as: ProductDatasource)
class ProductDatasourceRemote implements ProductDatasource {
  final ApiClient client;

  ProductDatasourceRemote(this.client);

  @override
  Future<Result<List<ProductModel>>> fetchAllProducts() async {
    return client.request(
      endpoint: APIEndpoint.allProducts,
      method: ApiMethod.get,
      decoder: (data) => (data as List<dynamic>).map((element) => ProductModel.fromJson(element)).toList(),
    );
  }
}
''',
  sampleRepositoryImplPath: r'''
import 'package:injectable/injectable.dart';
import 'package:sample_app/data/datasource/product/product_datasource.dart';
import 'package:sample_app/data/mappers/product_mapper.dart';
import 'package:sample_app/domain/core/result.dart';
import 'package:sample_app/domain/entities/product.dart';
import 'package:sample_app/domain/repositories/product/product_repository.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource remoteDatasource;

  ProductRepositoryImpl(this.remoteDatasource);

  @override
  Future<Result<List<Product>>> fetchAllProducts() async {
    final result = await remoteDatasource.fetchAllProducts();
    return switch (result) {
      Success(value: final models) => Success(models.map((e) => e.toEntity()).toList()),
      Failure(error: final error) => Failure(error),
    };
  }
}
''',
  sampleStatePath: r'''
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sample_app/domain/core/app_error.dart';
import 'package:sample_app/domain/entities/product.dart';

part 'product_state.freezed.dart';

@freezed
sealed class ProductState with _$ProductState {
  const factory ProductState.data({@Default([]) List<Product> products}) = ProductStateData;
  const factory ProductState.error(AppError error) = ProductStateError;
}
''',
  sampleViewmodelPath: r'''
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sample_app/domain/core/result.dart';
import 'package:sample_app/presentation/features/product/product_state.dart';
import 'package:sample_app/presentation/providers/di_providers.dart';

part 'product_viewmodel.g.dart';

@riverpod
class ProductViewmodel extends _$ProductViewmodel {
  @override
  FutureOr<ProductState> build() async {
    final useCase = ref.watch(productUseCaseProvider);
    final result = await useCase.fetchAllProducts();
    switch (result) {
      case Success(:final value):
        return ProductState.data(products: value);
      case Failure(:final error):
        return ProductState.error(error);
    }
  }
}
''',
  sampleScreenPath: r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
''',
  sampleItemViewPath: r'''
import 'package:flutter/material.dart';
import 'package:sample_app/domain/entities/product.dart';

class ProductItemView extends StatelessWidget {
  const ProductItemView({super.key, required this.data});

  final Product data;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''',
  sampleDiProvidersPath: r'''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/domain/use_cases/product/product_use_case.dart';
import 'package:sample_app/domain/use_cases/theme/theme_use_case.dart';
import 'package:sample_app/infrastructure/di/injection.dart';

final productUseCaseProvider = Provider<ProductUseCase>((ref) {
  return getIt<ProductUseCase>();
});

final themeUseCaseProvider = Provider<ThemeUseCase>((ref) {
  return getIt<ThemeUseCase>();
});
''',
  sampleApiEndpointPath: r'''
class APIEndpoint {
  static const baseUrl = 'https://example.com';

  static const String allProducts = '/all';
}
''',
  sampleRoutesPath: r'''
class AppRoutes {
  static const home = '/home';
  static const products = '/products';
  static const productsInHome = '/home/products';
}
''',
  sampleThemeRepositoryPath: r'''
import 'package:sample_app/domain/core/app_theme_mode.dart';

abstract class ThemeRepository {
  Future<AppThemeMode> fetch();

  Future<void> save(AppThemeMode theme);
}
''',
  sampleThemeUseCasePath: r'''
import 'package:injectable/injectable.dart';
import 'package:sample_app/domain/core/app_theme_mode.dart';
import 'package:sample_app/domain/repositories/theme/theme_repository.dart';

@lazySingleton
class ThemeUseCase {
  final ThemeRepository repository;

  ThemeUseCase(this.repository);

  Future<AppThemeMode> fetch() async {
    return repository.fetch();
  }

  Future<void> save(AppThemeMode theme) async {
    return repository.save(theme);
  }
}
''',
  sampleThemeRepositoryImplPath: r'''
import 'package:injectable/injectable.dart';
import 'package:sample_app/domain/core/app_theme_mode.dart';
import 'package:sample_app/domain/repositories/theme/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: ThemeRepository)
class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferences preferences;

  ThemeRepositoryImpl(this.preferences);

  @override
  Future<AppThemeMode> fetch() async {
    return AppThemeMode.system;
  }

  @override
  Future<void> save(AppThemeMode theme) async {
    await preferences.setString('theme_mode_key', theme.name);
  }
}
''',
  sampleThemeViewmodelPath: r'''
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sample_app/presentation/providers/di_providers.dart';

part 'theme_viewmodel.g.dart';

@riverpod
class ThemeViewmodel extends _$ThemeViewmodel {
  @override
  FutureOr<ThemeMode> build() async {
    final useCase = ref.watch(themeUseCaseProvider);
    await useCase.fetch();
    return ThemeMode.system;
  }
}
''',
};
