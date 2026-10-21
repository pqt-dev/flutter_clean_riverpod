import 'package:flutter_test/flutter_test.dart';

import 'checks/content_checks.dart';
import 'checks/layer_checks.dart';
import 'checks/structure_checks.dart';
import 'support/fixture.dart';
import 'support/project.dart';
import 'support/structure_helpers.dart';
import 'support/template_renderer.dart';

/// Template conformance: the templates in `.claude/templates/`, rendered for
/// features other than the sample Theme feature, must satisfy every automated rule.
/// Works even when the sample features have been deleted from the project.

const _apiSet = 'api-feature';
const _localSet = 'local-feature';

const _apiTokens = {
  'Entity': 'Product',
  'entity': 'product',
  'Entities': 'Products',
  'entities': 'products',
  'feature': 'product',
  'app_package': 'sample_app',
};
// The custom regions of the templates hard-code nested Name/Flag, so the main
// fixture renders the nested template for both.
const _apiNested = [
  {'Nested': 'Name', 'nested': 'name'},
  {'Nested': 'Flag', 'nested': 'flag'},
];
const _flagModelPath = 'lib/data/models/product/product_flag_model.dart';

const _localTokens = {
  'Feature': 'Language',
  'feature': 'language',
  'featureCamel': 'language',
  'ValueType': 'AppLanguage',
  'value_type': 'app_language',
  'storageKey': 'languageKey',
  'storage_key': 'language_key',
  'app_package': 'sample_app',
};
const _localLiterals = {'Theme': 'Language', 'theme': 'language'};

const _useCasePath = 'lib/domain/use_cases/product/product_use_case.dart';
const _viewmodelPath =
    'lib/presentation/features/product/product_viewmodel.dart';
const _mapperPath = 'lib/data/mappers/product_mapper.dart';
const _productTestPath = 'test/data/mappers/product_mapper_test.dart';

Map<String, String> _renderApi() {
  final api = renderTemplateSet(
    _apiSet,
    tokens: _apiTokens,
    nested: _apiNested,
  );
  // Simulates a developer rewriting the custom region consistently: the
  // nested template's custom region holds the Name fields (common/official),
  // so the Flag model gets the fields the mapper's custom region expects.
  api[_flagModelPath] = api[_flagModelPath]!.replaceFirst(
    RegExp(r'String\? common,\s*String\? official,'),
    'String? png, String? svg, String? alt,',
  );
  return api;
}

Map<String, String> _renderLocal() => renderTemplateSet(
  _localSet,
  tokens: _localTokens,
  literals: _localLiterals,
);

/// Shared files valid for the new names (per the SNIPPETS.md of both sets).
Map<String, String> _shared() => {
  ...validSharedFiles(),
  diProvidersFile: '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/domain/use_cases/language/language_use_case.dart';
import 'package:sample_app/domain/use_cases/product/product_use_case.dart';
import 'package:sample_app/infrastructure/di/injection.dart';

final languageUseCaseProvider = Provider<LanguageUseCase>((ref) {
  return getIt<LanguageUseCase>();
});

final productUseCaseProvider = Provider<ProductUseCase>((ref) {
  return getIt<ProductUseCase>();
});
''',
  apiEndpointFile: '''
class APIEndpoint {
  static const baseUrl = 'https://example.com';

  static const String allProducts = '/all';
}
''',
  appRoutesFile: '''
class AppRoutes {
  static const home = '/home';
  static const products = '/products';
  static const productsInHome = '/home/products';
}
''',
  storageKeysFile: '''
class StorageKeys {
  static const languageKey = 'language_key';
}
''',
  ...{
    for (final path in translationFiles)
      path:
          '{"home": "Home", "error_retry": "Retry", '
          '"error_unexpected": "Unexpected error", '
          '"go_to_products": "Go to products"}\n',
  },
};

/// The full rendered project (both template sets + shared files).
Map<String, String> _project() => {
  ..._shared(),
  ..._renderApi(),
  ..._renderLocal(),
};

/// Every automated check of the 3 groups, by rule id (45 rules). GEN-01 uses
/// the pure variant on the list of rendered files.
final Map<String, List<Violation> Function(ProjectRoot, List<String>)> _checks =
    {
      'ARC-01': (r, _) => checkArc01(r),
      'ARC-02': (r, _) => checkArc02(r),
      'ARC-03': (r, _) => checkArc03(r),
      'ARC-04': (r, _) => checkArc04(r),
      'ARC-05': (r, _) => checkArc05(r),
      'ARC-08': (r, _) => checkArc08(r),
      'FIL-01': (r, _) => checkFil01(r),
      'FIL-02': (r, _) => checkFil02(r),
      'FIL-03': (r, _) => checkFil03(r),
      'FIL-04': (r, _) => checkFil04(r),
      'FIL-05': (r, _) => checkFil05(r),
      'FIL-06': (r, _) => checkFil06(r),
      'FIL-07': (r, _) => checkFil07(r),
      'FIL-08': (r, _) => checkFil08(r),
      'FIL-09': (r, _) => checkFil09(r),
      'FIL-10': (r, _) => checkFil10(r),
      'TST-01': (r, _) => checkTst01(r),
      'TST-02': (r, _) => checkTst02(r),
      'TST-03': (r, _) => checkTst03(r),
      'NAM-12': (r, _) => checkNam12(r),
      'NAM-14': (r, _) => checkNam14(r),
      'L10N-02': (r, _) => checkL10n02(r),
      'L10N-03': (r, _) => checkL10n03(r),
      'GEN-01': (_, files) => checkGen01(files),
      'NAM-03': (r, _) => checkNam03(r),
      'NAM-04': (r, _) => checkNam04(r),
      'NAM-05': (r, _) => checkNam05(r),
      'NAM-06': (r, _) => checkNam06(r),
      'NAM-07': (r, _) => checkNam07(r),
      'NAM-08': (r, _) => checkNam08(r),
      'NAM-09': (r, _) => checkNam09(r),
      'NAM-10': (r, _) => checkNam10(r),
      'MET-01': (r, _) => checkMet01(r),
      'MET-05': (r, _) => checkMet05(r),
      'MET-06': (r, _) => checkMet06(r),
      'IMP-05': (r, _) => checkImp05(r),
      'CLS-01': (r, _) => checkCls01(r),
      'CLS-02': (r, _) => checkCls02(r),
      'CLS-03': (r, _) => checkCls03(r),
      'CLS-05': (r, _) => checkCls05(r),
      'CLS-06': (r, _) => checkCls06(r),
      'CLS-07': (r, _) => checkCls07(r),
      'CLS-08': (r, _) => checkCls08(r),
      'DI-01': (r, _) => checkDi01(r),
      'GEN-02': (r, _) => checkGen02(r),
    };

/// Rules whose test is parked pending a decision (rule id -> reason).
const Map<String, String> _pending = {};

/// Violations of [ruleId] on [files].
List<Violation> _run(String ruleId, Map<String, String> files) {
  final p = FixtureProject(files);
  addTearDown(p.dispose);
  return _checks[ruleId]!(p.root, files.keys.toList());
}

/// Renders the API set, applies [mutate] to it, and runs [ruleId] on the
/// whole project.
List<Violation> _runMutated(
  String ruleId,
  void Function(Map<String, String> apiFiles) mutate,
) {
  final api = _renderApi();
  mutate(api);
  return _run(ruleId, {..._shared(), ...api, ..._renderLocal()});
}

void main() {
  final hasApi = templateSetExists(_apiSet);
  final hasLocal = templateSetExists(_localSet);
  final missing = hasApi && hasLocal
      ? null
      : 'Template chưa có trong project này ($templatesDir/$_apiSet hoặc '
            '$_localSet không tồn tại)';

  test(
    'sanity: both template sets render and are discovered as 1 API + 1 local',
    () {
      final files = _project();
      final p = FixtureProject(files);
      addTearDown(p.dispose);
      final features = discoverFeatures(p.root);
      expect(features.map((f) => '${f.name}:${f.kind.name}').toSet(), {
        'product:api',
        'language:local',
      });
      expect(files.keys.where((k) => k.contains('{{')), isEmpty);
      expect(
        files.values.where(
          (v) => v.contains('{{') || v.contains('tmpl:custom'),
        ),
        isEmpty,
      );
      expect(
        files.keys,
        contains('lib/data/models/product/product_name_model.dart'),
      );
    },
    skip: missing,
  );

  group('rendered templates satisfy every rule', () {
    _checks.forEach((ruleId, _) {
      test(
        '$ruleId reports nothing on rendered api-feature + local-feature',
        () {
          final violations = _run(ruleId, _project());
          expect(
            violations,
            isEmpty,
            reason: violations.map((v) => '  $v').join('\n'),
          );
        },
        skip: missing ?? _pending[ruleId],
      );
    });
  });

  test(
    'nested model with a different name (detail): rules independent of the '
    'custom-region content hold',
    () {
      // MET-05 / CLS-02 are not run here: the custom regions of the mapper,
      // entity and model templates hard-code Name/Flag, so with nested=detail
      // they would (correctly) not match; their content is exercised by the
      // main fixture above.
      final api = renderTemplateSet(
        _apiSet,
        tokens: _apiTokens,
        nested: const [
          {'Nested': 'Detail', 'nested': 'detail'},
        ],
      );
      expect(
        api.keys,
        contains('lib/data/models/product/product_detail_model.dart'),
      );
      final files = {..._shared(), ...api, ..._renderLocal()};
      for (final ruleId in ['FIL-01', 'FIL-06', 'NAM-04', 'NAM-03']) {
        final violations = _run(ruleId, files);
        expect(
          violations,
          isEmpty,
          reason: '$ruleId:\n${violations.map((v) => '  $v').join('\n')}',
        );
      }
    },
    skip: missing,
  );

  group('negative: conformance test detects a corrupted template skeleton', () {
    test('NAM-03 catches a use case class without the UseCase suffix', () {
      final violations = _runMutated('NAM-03', (api) {
        api[_useCasePath] = api[_useCasePath]!.replaceAll(
          'ProductUseCase',
          'ProductService',
        );
      });
      expect(violations.map((v) => v.ruleId).toSet(), {'NAM-03'});
    }, skip: missing);

    test('FIL-01 catches a file dropped from the rendered api set', () {
      final violations = _runMutated('FIL-01', (api) {
        api.remove(_mapperPath);
      });
      expect(violations, isNotEmpty);
      expect(violations.map((v) => v.ruleId).toSet(), {'FIL-01'});
    }, skip: missing);

    test(
      'TST-02 catches a test file dropped from the rendered api set',
      () {
        final violations = _runMutated('TST-02', (api) {
          api.remove(_productTestPath);
        });
        expect(violations, isNotEmpty);
        expect(violations.map((v) => v.ruleId).toSet(), {'TST-02'});
      },
      skip: missing,
    );

    test('MET-01 catches a renamed fetchAllProducts method', () {
      final violations = _runMutated('MET-01', (api) {
        api[_useCasePath] = api[_useCasePath]!.replaceAll(
          'fetchAllProducts',
          'loadProducts',
        );
      });
      expect(violations, isNotEmpty);
      expect(violations.map((v) => v.ruleId).toSet(), {'MET-01'});
    }, skip: missing);

    test('MET-05 catches a nested field mapped without ?.toEntity()', () {
      final violations = _runMutated('MET-05', (api) {
        api[_mapperPath] = api[_mapperPath]!.replaceFirst(
          'name: name?.toEntity()',
          'name: name',
        );
      });
      expect(violations, isNotEmpty);
      expect(violations.map((v) => v.ruleId).toSet(), {'MET-05'});
    }, skip: missing);

    test('ARC-08 catches a print( added to a rendered file', () {
      final violations = _runMutated('ARC-08', (api) {
        api[_viewmodelPath] = api[_viewmodelPath]!.replaceFirst(
          'final result',
          "print('debug');\n    final result",
        );
      });
      expect(violations.map((v) => v.ruleId).toSet(), {'ARC-08'});
    }, skip: missing);

    test(
      'ARC-02 catches a relative import from presentation into data',
      () {
        final violations = _runMutated('ARC-02', (api) {
          api[_viewmodelPath] =
              "import '../../../data/repositories/product/product_repository_impl.dart';\n"
              '${api[_viewmodelPath]}';
        });
        expect(violations.map((v) => v.ruleId).toSet(), {'ARC-02'});
      },
      skip: missing,
    );
  });
}
