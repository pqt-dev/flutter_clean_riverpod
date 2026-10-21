import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'checks/structure_checks.dart';
import 'support/fixture.dart';
import 'support/project.dart';
import 'support/structure_helpers.dart';

final _real = ProjectRoot();

void _expectNoViolations(Iterable<Violation> violations) {
  expect(
    violations,
    isEmpty,
    reason: violations.map((v) => '  $v').join('\n'),
  );
}

/// Negative test: every fixture in [bad] must yield violations all carrying
/// [ruleId]; [good] must yield none.
void _negative(
  String ruleId,
  List<Violation> Function(ProjectRoot) check, {
  required Map<String, Map<String, String>> bad,
  required Map<String, String> good,
}) {
  bad.forEach((label, files) {
    test('$ruleId catches: $label', () {
      final p = FixtureProject(files);
      addTearDown(p.dispose);
      final violations = check(p.root);
      expect(violations, isNotEmpty);
      expect(violations.map((v) => v.ruleId).toSet(), {ruleId});
    });
  });

  test('$ruleId reports nothing for a valid fixture project', () {
    final p = FixtureProject(good);
    addTearDown(p.dispose);
    expect(check(p.root), isEmpty);
  });
}

/// Paths reported by [check] on a fixture.
Set<String> _paths(
  List<Violation> Function(ProjectRoot) check,
  Map<String, String> files,
) {
  final p = FixtureProject(files);
  addTearDown(p.dispose);
  return check(p.root).map((v) => v.path).toSet();
}

const _countryMapper = 'lib/data/mappers/country_mapper.dart';
const _themeRepoImpl = 'lib/data/repositories/theme/theme_repository_impl.dart';

final _validBoth = merged([
  validApiFeature(),
  validLocalFeature(),
  validSharedFiles(),
]);

void main() {
  // The real project may have no feature at all (fresh copy of the
  // boilerplate), so discovery is guarded on a fixture project instead.
  test('sanity: fixture project is discovered as 1 API + 1 local feature', () {
    final p = FixtureProject(_validBoth);
    addTearDown(p.dispose);
    final features = discoverFeatures(p.root);
    expect(features.map((f) => f.name).toSet(), {'country', 'theme'});
    expect(features.map((f) => f.kind).toSet(), {
      FeatureKind.api,
      FeatureKind.local,
    });
  });

  group('FIL-01 API feature file set', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil01(_real));
    });
    test('reports exactly the missing and the extra file', () {
      final files = {
        ...without(validApiFeature(), [_countryMapper]),
        'lib/data/models/country/extra.dart': '',
      };
      expect(_paths(checkFil01, files), {
        _countryMapper,
        'lib/data/models/country/extra.dart',
      });
    });
    _negative(
      'FIL-01',
      checkFil01,
      bad: {
        'missing mapper': without(validApiFeature(), [_countryMapper]),
        'extra file in feature dir': {
          ...validApiFeature(),
          'lib/domain/repositories/country/other.dart': '',
        },
        'extra test file': {
          ...validApiFeature(),
          'test/domain/use_cases/country/other_test.dart': '',
        },
        'missing screen': without(validApiFeature(), [
          'lib/presentation/features/country/countries_screen.dart',
        ]),
        'no use case, entity unknown': {
          ...without(validApiFeature(), [
            'lib/domain/use_cases/country/country_use_case.dart',
          ]),
          'lib/domain/use_cases/country/other.dart': '',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-02 local feature file set', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil02(_real));
    });
    test('reports exactly the missing and the extra file', () {
      final files = {
        ...without(validLocalFeature(), [_themeRepoImpl]),
        'lib/domain/use_cases/theme/extra.dart': '',
      };
      expect(_paths(checkFil02, files), {
        _themeRepoImpl,
        'lib/domain/use_cases/theme/extra.dart',
      });
    });
    _negative(
      'FIL-02',
      checkFil02,
      bad: {
        'missing repository impl': without(validLocalFeature(), [
          _themeRepoImpl,
        ]),
        'missing viewmodel test': without(validLocalFeature(), [
          'test/presentation/theme/theme_viewmodel_test.dart',
        ]),
        'extra file': {
          ...validLocalFeature(),
          'lib/data/models/theme/theme_model.dart': '',
        },
        'extra UI file other than the documented ones': {
          ...validLocalFeature(),
          'lib/presentation/theme/other_widget.dart': '',
        },
      },
      good: {
        ..._validBoth,
        'lib/presentation/theme/app_theme.dart': '',
        'lib/presentation/theme/app_theme_extension.dart': '',
      },
    );
  });

  group('FIL-03 directory names', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil03(_real));
    });
    _negative(
      'FIL-03',
      checkFil03,
      bad: {
        'datasources (plural)': {'lib/data/datasources/country/a.dart': ''},
        'repository (singular)': {'lib/domain/repository/country/a.dart': ''},
        'usecases': {'lib/domain/usecases/country/a.dart': ''},
        'plural feature dir': {'lib/domain/use_cases/countries/a.dart': ''},
        'models dir in test mirror': {'test/data/model/a_test.dart': ''},
        'widgets dir inside feature': {
          ...validApiFeature(),
          'lib/presentation/features/country/widgets/a.dart': '',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-04 same feature name across directories', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil04(_real));
    });
    _negative(
      'FIL-04',
      checkFil04,
      bad: {
        'repository dir with another name': {
          ...validApiFeature(),
          'lib/domain/repositories/nation/a.dart': '',
        },
        'models dir with another name': {
          ...validApiFeature(),
          'lib/data/models/countries/a.dart': '',
        },
        'test dir with another name': {
          ...validApiFeature(),
          'test/data/repositories/nation/a_test.dart': '',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-05 entities in one flat file', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil05(_real));
    });
    _negative(
      'FIL-05',
      checkFil05,
      bad: {
        'entity in feature subdir': {
          ...validApiFeature(),
          'lib/domain/entities/country/country.dart': '',
        },
        'nested entity in its own file': {
          ...validApiFeature(),
          'lib/domain/entities/country_name.dart': '',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-06 one class per model file', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil06(_real));
    });
    _negative(
      'FIL-06',
      checkFil06,
      bad: {
        'two classes in one model file': {
          ...validApiFeature(),
          'lib/data/models/country/country_model.dart':
              'class CountryModel {}\nclass CountryNameModel {}\n',
        },
        'model file without class': {
          ...validApiFeature(),
          'lib/data/models/country/country_model.dart': '// empty\n',
        },
        'model outside feature dir': {
          ...validApiFeature(),
          'lib/data/country_flag_model.dart': 'class CountryFlagModel {}\n',
        },
        'model in unknown feature dir': {
          ...validApiFeature(),
          'lib/data/models/other/a_model.dart': 'class AModel {}\n',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-07 flat mappers', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil07(_real));
    });
    _negative(
      'FIL-07',
      checkFil07,
      bad: {
        'mapper in feature subdir': {
          ...validApiFeature(),
          'lib/data/mappers/country/country_mapper.dart': '',
        },
        'nested mapper in its own file': {
          ...validApiFeature(),
          'lib/data/mappers/country_name_mapper.dart': '',
        },
        'mapper outside data/mappers': {
          ...validApiFeature(),
          'lib/data/models/country/other_mapper.dart':
              'extension on Object { int toEntity() => 1; }\n',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-08 presentation location', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil08(_real));
    });
    _negative(
      'FIL-08',
      checkFil08,
      bad: {
        'API feature presentation at presentation/<f>': {
          ...validApiFeature(),
          'lib/presentation/country/a.dart': '',
        },
        'local feature presentation under features/': {
          ...validLocalFeature(),
          'lib/presentation/features/theme/a.dart': '',
        },
        'item view not in widget/': {
          ...validApiFeature(),
          'lib/presentation/features/country/other_item_view.dart': '',
        },
        'item view in nested widget dir': {
          ...validApiFeature(),
          'lib/presentation/features/country/widget/sub/other_item_view.dart':
              '',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-09 local enum in domain/core', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil09(_real));
    });
    _negative(
      'FIL-09',
      checkFil09,
      bad: {
        'enum declared in the viewmodel': {
          ...validLocalFeature(),
          'lib/presentation/theme/theme_viewmodel.dart': 'enum Mode { a }\n',
        },
        'repository imports no core value type': {
          ...validLocalFeature(),
          'lib/domain/repositories/theme/theme_repository.dart':
              'abstract class ThemeRepository {}\n',
        },
        'value enum file missing': without(validLocalFeature(), [
          'lib/domain/core/app_theme_mode.dart',
        ]),
        'value file declares no enum': {
          ...validLocalFeature(),
          'lib/domain/core/app_theme_mode.dart': 'class AppThemeMode {}\n',
        },
      },
      good: _validBoth,
    );
  });

  group('FIL-10 shared files', () {
    test('real project has no violations', () {
      _expectNoViolations(checkFil10(_real));
    });
    _negative(
      'FIL-10',
      checkFil10,
      bad: {
        'APIEndpoint declared in another file': {
          ..._validBoth,
          'lib/data/datasource/country/endpoints.dart':
              'class APIEndpoint {}\n',
        },
        'StorageKeys declared in another file': {
          ..._validBoth,
          'lib/infrastructure/constants/other.dart': 'class StorageKeys {}\n',
        },
        'AppRoutes declared in another file': {
          ..._validBoth,
          'lib/presentation/router/other.dart': 'class AppRoutes {}\n',
        },
        'use case provider outside di_providers': {
          ..._validBoth,
          'lib/presentation/providers/other.dart':
              'final themeUseCaseProvider = 1;\n',
        },
        'new routes file': {
          ..._validBoth,
          'lib/presentation/router/more_routes.dart': '',
        },
        'missing di_providers': without(_validBoth, [diProvidersFile]),
        'missing api_endpoint for API feature': without(_validBoth, [
          apiEndpointFile,
        ]),
      },
      good: _validBoth,
    );
  });

  group('TST-01 test mirrors lib', () {
    test(
      'real project has no violations',
      () {
        _expectNoViolations(checkTst01(_real));
      },
    );
    _negative(
      'TST-01',
      checkTst01,
      bad: {
        'test without source': {
          'lib/a/b.dart': '',
          'test/a/c_test.dart': 'void main() {}\n',
        },
        'test in wrong dir': {
          'lib/a/b.dart': '',
          'test/x/b_test.dart': 'void main() {}\n',
        },
        'test file without _test suffix': {
          'lib/a/b.dart': '',
          'test/a/b.dart': 'void main() {}\n',
        },
      },
      good: {
        'lib/a/b.dart': '',
        'test/a/b_test.dart': 'void main() {}\n',
        'test/architecture/whatever_test.dart': 'void main() {}\n',
      },
    );
  });

  group('TST-02 required test files', () {
    test('real project has no violations', () {
      _expectNoViolations(checkTst02(_real));
    });
    test('reports exactly the missing test file', () {
      const missing = 'test/data/mappers/country_mapper_test.dart';
      expect(_paths(checkTst02, without(validApiFeature(), [missing])), {
        missing,
      });
    });
    _negative(
      'TST-02',
      checkTst02,
      bad: {
        'API feature without mapper test': without(validApiFeature(), [
          'test/data/mappers/country_mapper_test.dart',
        ]),
        'API feature without viewmodel test': without(validApiFeature(), [
          'test/presentation/features/country/country_viewmodel_test.dart',
        ]),
        'local feature without use case test': without(validLocalFeature(), [
          'test/domain/use_cases/theme/theme_use_case_test.dart',
        ]),
        'test at a non-mirror path': {
          ...without(validLocalFeature(), [
            'test/presentation/theme/theme_viewmodel_test.dart',
          ]),
          'test/presentation/features/theme/theme_viewmodel_test.dart':
              'void main() {}\n',
        },
      },
      good: _validBoth,
    );
  });

  const goodMockTest = '''
import 'package:mockito/annotations.dart';

import 'a_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Foo>(), MockSpec<Bar>()])
void main() {
  final a = MockFoo();
  final b = MockBar();
}
''';

  group('TST-03 main and mocks', () {
    test('real project has no violations', () {
      _expectNoViolations(checkTst03(_real));
    });
    _negative(
      'TST-03',
      checkTst03,
      bad: {
        'no void main()': {'test/a_test.dart': 'void other() {}\n'},
        'mocks import without annotation': {
          'test/a_test.dart':
              "import 'a_test.mocks.dart';\nvoid main() { MockFoo(); }\n",
        },
        'annotation not right above main': {
          'test/a_test.dart': '''
import 'a_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Foo>()])
final x = 1;

void main() {}
''',
        },
        'annotation without mocks import': {
          'test/a_test.dart': '''
@GenerateNiceMocks([MockSpec<Foo>()])
void main() {}
''',
        },
        'mocks import of another file': {
          'test/a_test.dart': '''
import 'b_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Foo>()])
void main() {}
''',
        },
      },
      good: {
        'test/a_test.dart': goodMockTest,
        'test/b_test.dart': 'void main() {}\n',
        'test/c_test.dart': '''
import 'c_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Foo>(),
])
void main() {}
''',
      },
    );
  });

  group('NAM-12 test file and mock names', () {
    test('real project has no violations', () {
      _expectNoViolations(checkNam12(_real));
    });
    _negative(
      'NAM-12',
      checkNam12,
      bad: {
        'test file without _test suffix': {'test/a/foo.dart': ''},
        'mock file not named {x}_test.mocks.dart': {
          'test/a/foo_test.dart': 'void main() {}\n',
          'test/a/foo.mocks.dart': '',
        },
        'mock file without matching test': {
          'test/a/foo_test.dart': 'void main() {}\n',
          'test/a/bar_test.mocks.dart': '',
        },
        'mock class not Mock{Class}': {
          'test/a/foo_test.dart': '''
@GenerateNiceMocks([MockSpec<Foo>()])
void main() {
  final a = MockFooBar();
}
''',
        },
      },
      good: {
        'test/a/foo_test.dart': goodMockTest,
        'test/a/foo_test.mocks.dart': '',
        'test/a/foo_test.dart.bak': '',
      },
    );
  });

  group('NAM-14 l10n keys flat snake_case', () {
    test('real project has no violations', () {
      _expectNoViolations(checkNam14(_real));
    });
    _negative(
      'NAM-14',
      checkNam14,
      bad: {
        'camelCase key': {
          ...validTranslations(),
          translationFiles[0]: '{"errorRetry": "Retry"}',
        },
        'kebab key': {
          ...validTranslations(),
          translationFiles[1]: '{"error-retry": "Retry"}',
        },
        'nested object': {
          ...validTranslations(),
          translationFiles[2]: '{"error": {"retry": "Retry"}}',
        },
      },
      good: validTranslations(),
    );
  });

  group('L10N-02 same keys in 3 translation files', () {
    test('real project has no violations', () {
      _expectNoViolations(checkL10n02(_real));
    });
    test('reports the file missing the key', () {
      final files = {
        ...validTranslations(),
        translationFiles[1]: '{"home": "x"}',
      };
      expect(_paths(checkL10n02, files), {translationFiles[1]});
    });
    _negative(
      'L10N-02',
      checkL10n02,
      bad: {
        'key missing in one file': {
          ...validTranslations(),
          translationFiles[2]: '{"home": "x"}',
        },
        'extra key in one file': {
          ...validTranslations(),
          translationFiles[0]: '{"home": "x", "error_retry": "y", "more": "z"}',
        },
        'invalid JSON': {
          ...validTranslations(),
          translationFiles[0]: '{"home": ',
        },
        'file missing': without(validTranslations(), [translationFiles[1]]),
      },
      good: validTranslations(),
    );
  });

  group('L10N-03 .tr() and LocaleKeys only in presentation', () {
    test('real project has no violations', () {
      _expectNoViolations(checkL10n03(_real));
    });
    _negative(
      'L10N-03',
      checkL10n03,
      bad: {
        '.tr() in data': {'lib/data/a.dart': "final t = 'a'.tr();\n"},
        'LocaleKeys in domain': {
          'lib/domain/a.dart': 'final t = LocaleKeys.home;\n',
        },
        'LocaleKeys in lib root': {
          'lib/main.dart': 'final t = LocaleKeys.home.tr();\n',
        },
      },
      good: {
        'lib/presentation/a.dart': 'final t = LocaleKeys.home.tr();\n',
        'lib/data/a.dart': "// 'a'.tr() in a comment\nfinal x = 1;\n",
        'lib/generated/locale_keys.g.dart': 'abstract class LocaleKeys {}\n',
      },
    );
  });

  group('GEN-01 generated files are not tracked', () {
    test('real project has no violations', () {
      _expectNoViolations(checkGen01OnProject(_real));
    });
    test('pure check catches tracked generated files', () {
      final violations = checkGen01([
        'lib/a.dart',
        'lib/a.g.dart',
        'lib/a.freezed.dart',
        'lib/injection.config.dart',
        'lib/generated/assets.gen.dart',
        'test/a_test.mocks.dart',
      ]);
      expect(violations.map((v) => v.ruleId).toSet(), {'GEN-01'});
      expect(violations.map((v) => v.path), [
        'lib/a.g.dart',
        'lib/a.freezed.dart',
        'lib/injection.config.dart',
        'lib/generated/assets.gen.dart',
        'test/a_test.mocks.dart',
      ]);
    });
    test('pure check reports nothing for ordinary files', () {
      expect(checkGen01(['lib/a.dart', 'pubspec.yaml', '.gitignore']), isEmpty);
    });
    test('wrapper reports nothing when root is not a git repository', () {
      final p = FixtureProject({'lib/a.g.dart': ''});
      addTearDown(p.dispose);
      expect(checkGen01OnProject(p.root), isEmpty);
    });
    test('wrapper catches a generated file tracked in a git repository', () {
      if (Process.runSync('git', ['--version']).exitCode != 0) {
        markTestSkipped('git not available');
        return;
      }
      final p = FixtureProject({'lib/a.dart': '', 'lib/a.g.dart': ''});
      addTearDown(p.dispose);
      for (final args in [
        ['init', '-q'],
        ['add', '-A'],
      ]) {
        final r = Process.runSync('git', ['-C', p.root.path, ...args]);
        expect(r.exitCode, 0, reason: '${r.stderr}');
      }
      final violations = checkGen01OnProject(p.root);
      expect(violations.map((v) => v.path), ['lib/a.g.dart']);
    });
  });
}
