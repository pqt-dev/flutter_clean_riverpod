import 'package:flutter_test/flutter_test.dart';

import 'checks/content_checks.dart';
import 'support/fixture.dart';
import 'support/project.dart';
import 'support/source_helpers.dart';

final _real = ProjectRoot();

void _expectNoViolations(Iterable<Violation> violations) {
  expect(
    violations,
    isEmpty,
    reason: violations.map((v) => '  $v').join('\n'),
  );
}

/// Real-project test. [skipReason] marks a rule awaiting a decision.
void _real_(
  List<Violation> Function(ProjectRoot) check, {
  String? skipReason,
}) {
  test('real project has no violations', () {
    _expectNoViolations(check(_real));
  }, skip: skipReason);
}

/// Negative tests: every case in [bad] (description -> fixture files) must
/// yield violations all carrying [ruleId]; the valid [sampleProject] must
/// yield none.
void _negative(
  String ruleId,
  List<Violation> Function(ProjectRoot) check, {
  required Map<String, Map<String, String> Function(Map<String, String>)> bad,
}) {
  bad.forEach((description, mutate) {
    test('$ruleId catches: $description', () {
      final p = FixtureProject(mutate(sampleProject()));
      addTearDown(p.dispose);
      final violations = check(p.root);
      expect(violations, isNotEmpty);
      expect(violations.map((v) => v.ruleId).toSet(), {ruleId});
    });
  });

  test('$ruleId reports nothing for a valid fixture project', () {
    final p = FixtureProject(sampleProject());
    addTearDown(p.dispose);
    _expectNoViolations(check(p.root));
  });
}

void main() {
  // The real project may have 0, only API, only local, or both kinds of
  // features (a fresh copy of the boilerplate has no API feature). Only the
  // plural-from-screen constraint is checked on features that exist; the
  // "not an empty pass" guard lives in the sample fixture sanity below.
  test('sanity: every real API feature has a *_screen.dart plural', () {
    for (final c in featureContexts(_real).where((c) => c.isApi)) {
      expect(c.plural, isNotNull, reason: '${c.name} has no *_screen.dart');
    }
  });

  test('sanity: sample fixture is discovered as 1 API + 1 local feature', () {
    final p = FixtureProject(sampleProject());
    addTearDown(p.dispose);
    final contexts = featureContexts(p.root);
    expect(contexts.map((c) => c.name), ['product', 'theme']);
    expect(contexts.first.plural, 'products');
    expect(contexts.first.isApi, isTrue);
    expect(contexts.last.isApi, isFalse);
  });

  group('NAM-03 class names', () {
    _real_(checkNam03);
    _negative(
      'NAM-03',
      checkNam03,
      bad: {
        'repository impl suffix changed': (f) => mutated(
          f,
          sampleRepositoryImplPath,
          'ProductRepositoryImpl',
          'ProductRepoImpl',
        ),
        'datasource remote suffix changed': (f) => mutated(
          f,
          sampleRemotePath,
          'ProductDatasourceRemote',
          'ProductRemoteDatasource',
        ),
        'screen class does not match file': (f) => mutated(
          f,
          sampleScreenPath,
          'ProductsScreen',
          'ProductsPage',
        ),
        'local use case renamed': (f) =>
            mutated(f, sampleThemeUseCasePath, 'ThemeUseCase', 'ThemeUseCases'),
      },
    );
  });

  group('NAM-04 nested names', () {
    _real_(checkNam04);
    _negative(
      'NAM-04',
      checkNam04,
      bad: {
        'nested entity without Entity prefix': (f) =>
            mutated(f, sampleEntityPath, 'ProductName', 'Name'),
        'nested model class renamed': (f) => mutated(
          f,
          sampleNestedModelPath,
          'ProductNameModel',
          'NameModel',
        ),
        'nested mapper extension renamed': (f) => mutated(
          f,
          sampleMapperPath,
          'ProductNameModelMapper',
          'ProductNameMapper',
        ),
      },
    );
  });

  group('NAM-05 entity suffix', () {
    _real_(checkNam05);
    _negative(
      'NAM-05',
      checkNam05,
      bad: {
        'Dto suffix': (f) =>
            mutated(f, sampleEntityPath, 'ProductName', 'ProductDto'),
        'Entity suffix': (f) => mutated(
          f,
          sampleEntityPath,
          'abstract class Product ',
          'abstract class ProductEntity ',
        ).map((k, v) => MapEntry(k, v)),
      },
    );
  });

  group('NAM-06 Viewmodel spelling', () {
    _real_(checkNam06);
    _negative(
      'NAM-06',
      checkNam06,
      bad: {
        'ViewModel class': (f) =>
            mutated(f, sampleViewmodelPath, 'Viewmodel', 'ViewModel'),
        'ViewModel provider': (f) => mutated(
          f,
          sampleThemeViewmodelPath,
          'ThemeViewmodel',
          'ThemeViewModel',
        ),
        'view_model file name': (f) => renamed(
          f,
          sampleViewmodelPath,
          'lib/presentation/features/product/product_view_model.dart',
        ),
      },
    );
  });

  group('NAM-07 plural screen, singular rest', () {
    _real_(checkNam07);
    _negative(
      'NAM-07',
      checkNam07,
      bad: {
        'singular screen': (f) => renamed(
          f,
          sampleScreenPath,
          'lib/presentation/features/product/product_screen.dart',
        ),
        'plural repository file': (f) => renamed(
          f,
          sampleRepositoryPath,
          'lib/domain/repositories/product/products_repository.dart',
        ),
        'plural class outside screen': (f) => mutated(
          f,
          sampleRepositoryPath,
          'ProductRepository',
          'ProductsRepository',
        ),
      },
    );
  });

  group('NAM-08 DI provider name', () {
    _real_(checkNam08);
    _negative(
      'NAM-08',
      checkNam08,
      bad: {
        'provider misnamed': (f) => mutated(
          f,
          sampleDiProvidersPath,
          'productUseCaseProvider',
          'productsUseCaseProvider',
        ),
        'two providers for one use case': (f) => mutated(
          f,
          sampleDiProvidersPath,
          'final themeUseCaseProvider',
          'final extraProductUseCaseProvider = Provider<ProductUseCase>((ref) {\n'
              '  return getIt<ProductUseCase>();\n'
              '});\n\n'
              'final themeUseCaseProvider',
        ),
        'use case without provider': (f) => mutated(
          f,
          sampleDiProvidersPath,
          'final themeUseCaseProvider = Provider<ThemeUseCase>',
          'final themeUseCaseProvider = Provider<Object>',
        ),
      },
    );
  });

  group('NAM-09 APIEndpoint.all{Entities}', () {
    _real_(checkNam09);
    _negative(
      'NAM-09',
      checkNam09,
      bad: {
        'constant misnamed': (f) =>
            mutated(f, sampleApiEndpointPath, 'allProducts', 'productsAll'),
        'class casing': (f) =>
            mutated(f, sampleApiEndpointPath, 'APIEndpoint', 'ApiEndpoint'),
      },
    );
  });

  group('NAM-10 route constant pair', () {
    _real_(checkNam10);
    _negative(
      'NAM-10',
      checkNam10,
      bad: {
        'InHome constant misnamed': (f) =>
            mutated(f, sampleRoutesPath, 'productsInHome', 'productsHome'),
        'path wrong': (f) => mutated(
          f,
          sampleRoutesPath,
          "'/home/products'",
          "'/products/home'",
        ),
        'plain constant missing': (f) =>
            mutated(f, sampleRoutesPath, 'products =', 'productList ='),
      },
    );
  });

  group('MET-01 fetchAll{Entities}', () {
    _real_(checkMet01);
    _negative(
      'MET-01',
      checkMet01,
      bad: {
        'datasource renamed': (f) => mutated(
          f,
          sampleDatasourcePath,
          'fetchAllProducts',
          'getProducts',
        ),
        'use case renamed': (f) =>
            mutated(f, sampleUseCasePath, 'fetchAllProducts', 'fetchAll'),
        'repository impl renamed': (f) => mutated(
          f,
          sampleRepositoryImplPath,
          'Future<Result<List<Product>>> fetchAllProducts()',
          'Future<Result<List<Product>>> fetchProducts()',
        ),
      },
    );
  });

  group('MET-05 mapper toEntity', () {
    _real_(checkMet05);
    _negative(
      'MET-05',
      checkMet05,
      bad: {
        'method renamed': (f) => mutated(
          f,
          sampleMapperPath,
          'Product toEntity()',
          'Product toDomain()',
        ),
        'nested model not mapped with ?.toEntity()': (f) => mutated(
          f,
          sampleMapperPath,
          'name: name?.toEntity()',
          'name: name',
        ),
        'field not mapped': (f) =>
            mutated(f, sampleMapperPath, 'region: region,', ''),
        'body is not return X(...)': (f) => mutated(
          f,
          sampleMapperPath,
          'ProductName toEntity() {\n    return ProductName(\n      common: common,\n    );\n  }',
          'ProductName toEntity() => ProductName(common: common);',
        ),
        'two toEntity in one extension': (f) => mutated(
          f,
          sampleMapperPath,
          '  Product toEntity() {',
          '  Product toEntity(){return Product();}\n  Product toEntity() {',
        ),
      },
    );
  });

  group('MET-06 fromJson only in Model', () {
    _real_(checkMet06);
    _negative(
      'MET-06',
      checkMet06,
      bad: {
        'entity has fromJson': (f) => mutated(
          f,
          sampleEntityPath,
          '  }) = _Product;',
          '  }) = _Product;\n\n  factory Product.fromJson(Map<String, dynamic> json) => _\$ProductFromJson(json);',
        ),
        'model fromJson deviates': (f) => mutated(
          f,
          sampleModelPath,
          '_\$ProductModelFromJson(json)',
          'ProductModel()',
        ),
        'model without fromJson': (f) => mutated(
          f,
          sampleNestedModelPath,
          'factory ProductNameModel.fromJson(Map<String, dynamic> json) => _\$ProductNameModelFromJson(json);',
          '',
        ),
        'fromJson declared outside models': (f) => mutated(
          f,
          sampleStatePath,
          '  const factory ProductState.error',
          '  factory ProductState.fromJson(Map<String, dynamic> json) => ProductState.data();\n  const factory ProductState.error',
        ),
      },
    );
  });

  group('IMP-05 part placement', () {
    _real_(checkImp05);
    _negative(
      'IMP-05',
      checkImp05,
      bad: {
        '.g.dart before .freezed.dart': (f) => mutated(
          f,
          sampleModelPath,
          "part 'product_model.freezed.dart';\npart 'product_model.g.dart';",
          "part 'product_model.g.dart';\npart 'product_model.freezed.dart';",
        ),
        'no blank line after imports': (f) => mutated(
          f,
          sampleEntityPath,
          "freezed_annotation.dart';\n\npart",
          "freezed_annotation.dart';\npart",
        ),
        'two blank lines after imports': (f) => mutated(
          f,
          sampleEntityPath,
          "freezed_annotation.dart';\n\npart",
          "freezed_annotation.dart';\n\n\npart",
        ),
        'blank line between parts': (f) => mutated(
          f,
          sampleModelPath,
          "part 'product_model.freezed.dart';\npart",
          "part 'product_model.freezed.dart';\n\npart",
        ),
        'part with a path': (f) => mutated(
          f,
          sampleStatePath,
          "part 'product_state.freezed.dart';",
          "part 'generated/product_state.freezed.dart';",
        ),
        'part before imports': (f) => {
          ...f,
          sampleEntityPath:
              "part 'product.freezed.dart';\n\nimport 'package:freezed_annotation/freezed_annotation.dart';\n\n${f[sampleEntityPath]!.split("\n\n").skip(2).join("\n\n")}",
        },
      },
    );
  });

  group('CLS-01 entity declaration', () {
    _real_(checkCls01);
    _negative(
      'CLS-01',
      checkCls01,
      bad: {
        'missing @freezed': (f) => mutated(
          f,
          sampleEntityPath,
          '@freezed\nabstract class Product with',
          'abstract class Product with',
        ),
        'not abstract': (f) => mutated(
          f,
          sampleEntityPath,
          'abstract class ProductName',
          'class ProductName',
        ),
        'extra .g.dart part': (f) => mutated(
          f,
          sampleEntityPath,
          "part 'product.freezed.dart';",
          "part 'product.freezed.dart';\npart 'product.g.dart';",
        ),
        'factory not assigned to private class': (f) => mutated(
          f,
          sampleEntityPath,
          '}) = _ProductName;',
          '}) = ProductNameImpl;',
        ),
      },
    );
  });

  group('CLS-02 model declaration', () {
    _real_(checkCls02);
    _negative(
      'CLS-02',
      checkCls02,
      bad: {
        'missing .g.dart part': (f) => mutated(
          f,
          sampleModelPath,
          "part 'product_model.g.dart';\n",
          '',
        ),
        'nested field typed as entity': (f) => mutated(
          f,
          sampleModelPath,
          'ProductNameModel? name',
          'ProductName? name',
        ),
        'missing fromJson': (f) => mutated(
          f,
          sampleNestedModelPath,
          'factory ProductNameModel.fromJson(Map<String, dynamic> json) => _\$ProductNameModelFromJson(json);',
          '',
        ),
        'not abstract': (f) => mutated(
          f,
          sampleModelPath,
          'abstract class ProductModel',
          'class ProductModel',
        ),
      },
    );
  });

  group('CLS-03 state declaration', () {
    _real_(checkCls03);
    _negative(
      'CLS-03',
      checkCls03,
      bad: {
        'not sealed': (f) =>
            mutated(f, sampleStatePath, 'sealed class', 'abstract class'),
        'extra factory': (f) => mutated(
          f,
          sampleStatePath,
          '  const factory ProductState.error',
          '  const factory ProductState.loading() = ProductStateLoading;\n  const factory ProductState.error',
        ),
        'missing @Default([])': (f) =>
            mutated(f, sampleStatePath, '@Default([]) ', ''),
        'wrong list field name': (f) => mutated(
          f,
          sampleStatePath,
          'List<Product> products',
          'List<Product> items',
        ),
        'extra .g.dart part': (f) => mutated(
          f,
          sampleStatePath,
          "part 'product_state.freezed.dart';",
          "part 'product_state.freezed.dart';\npart 'product_state.g.dart';",
        ),
      },
    );
  });

  group('CLS-05 datasource remote / repository impl', () {
    _real_(checkCls05);
    _negative(
      'CLS-05',
      checkCls05,
      bad: {
        'datasource extends instead of implements': (f) => mutated(
          f,
          sampleRemotePath,
          'implements ProductDatasource',
          'extends ProductDatasource',
        ),
        'repository impl without as:': (f) => mutated(
          f,
          sampleRepositoryImplPath,
          '@LazySingleton(as: ProductRepository)',
          '@LazySingleton()',
        ),
        'local repository impl extends': (f) => mutated(
          f,
          sampleThemeRepositoryImplPath,
          'implements ThemeRepository',
          'extends ThemeRepository',
        ),
      },
    );
  });

  group('CLS-06 use case declaration', () {
    _real_(checkCls06);
    _negative(
      'CLS-06',
      checkCls06,
      bad: {
        'missing @lazySingleton': (f) =>
            mutated(f, sampleUseCasePath, '@lazySingleton\n', ''),
        'abstract use case': (f) => mutated(
          f,
          sampleUseCasePath,
          'class ProductUseCase',
          'abstract class ProductUseCase',
        ),
        'local use case without annotation': (f) =>
            mutated(f, sampleThemeUseCasePath, '@lazySingleton\n', ''),
      },
    );
  });

  group('CLS-07 viewmodel declaration', () {
    _real_(checkCls07);
    _negative(
      'CLS-07',
      checkCls07,
      bad: {
        'missing @override': (f) => mutated(
          f,
          sampleViewmodelPath,
          '  @override\n  FutureOr',
          '  FutureOr',
        ),
        'missing .g.dart part': (f) => mutated(
          f,
          sampleViewmodelPath,
          "part 'product_viewmodel.g.dart';",
          '',
        ),
        'missing riverpod_annotation import': (f) => mutated(
          f,
          sampleViewmodelPath,
          "import 'package:riverpod_annotation/riverpod_annotation.dart';\n",
          '',
        ),
        '@riverpod with arguments': (f) => mutated(
          f,
          sampleViewmodelPath,
          '@riverpod\n',
          '@riverpod()\n',
        ),
        'does not extend generated base': (f) => mutated(
          f,
          sampleThemeViewmodelPath,
          'extends _\$ThemeViewmodel',
          'extends Notifier<ThemeMode>',
        ),
      },
    );
  });

  group('CLS-08 screen / item view declaration', () {
    _real_(checkCls08);
    _negative(
      'CLS-08',
      checkCls08,
      bad: {
        'screen not ConsumerWidget': (f) => mutated(
          f,
          sampleScreenPath,
          'extends ConsumerWidget',
          'extends StatelessWidget',
        ),
        'screen constructor not const': (f) => mutated(
          f,
          sampleScreenPath,
          'const ProductsScreen({super.key});',
          'ProductsScreen({super.key});',
        ),
        'item view not StatelessWidget': (f) => mutated(
          f,
          sampleItemViewPath,
          'extends StatelessWidget',
          'extends StatefulWidget',
        ),
        'item view without required data': (f) => mutated(
          f,
          sampleItemViewPath,
          'const ProductItemView({super.key, required this.data});',
          'const ProductItemView({super.key, this.data});',
        ),
      },
    );
  });

  group('DI-01 injectable annotations', () {
    _real_(checkDi01);
    _negative(
      'DI-01',
      checkDi01,
      bad: {
        '@injectable on use case': (f) => mutated(
          f,
          sampleUseCasePath,
          '@lazySingleton\n',
          '@lazySingleton\n@injectable\n',
        ),
        '@singleton on repository impl': (f) => mutated(
          f,
          sampleRepositoryImplPath,
          '@LazySingleton(as: ProductRepository)',
          '@LazySingleton(as: ProductRepository)\n@singleton',
        ),
        'use case without annotation': (f) =>
            mutated(f, sampleUseCasePath, '@lazySingleton\n', ''),
        'datasource remote without as:': (f) => mutated(
          f,
          sampleRemotePath,
          '@LazySingleton(as: ProductDatasource)',
          '@LazySingleton()',
        ),
      },
    );
  });

  group('GEN-02 part matches annotation', () {
    _real_(checkGen02);
    _negative(
      'GEN-02',
      checkGen02,
      bad: {
        '@freezed without .freezed.dart': (f) => mutated(
          f,
          sampleEntityPath,
          "part 'product.freezed.dart';",
          '',
        ),
        'fromJson without .g.dart': (f) => mutated(
          f,
          sampleNestedModelPath,
          "part 'product_name_model.g.dart';\n",
          '',
        ),
        '@riverpod without .g.dart': (f) => mutated(
          f,
          sampleThemeViewmodelPath,
          "part 'theme_viewmodel.g.dart';",
          '',
        ),
        '.freezed.dart part without @freezed': (f) => mutated(
          f,
          sampleStatePath,
          '@freezed\n',
          '',
        ),
      },
    );
  });
}
