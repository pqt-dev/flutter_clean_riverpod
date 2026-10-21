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
  // features (a fresh copy of the boilerplate has none of Country). Only the
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
    expect(contexts.map((c) => c.name), ['country', 'theme']);
    expect(contexts.first.plural, 'countries');
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
          'CountryRepositoryImpl',
          'CountryRepoImpl',
        ),
        'datasource remote suffix changed': (f) => mutated(
          f,
          sampleRemotePath,
          'CountryDatasourceRemote',
          'CountryRemoteDatasource',
        ),
        'screen class does not match file': (f) => mutated(
          f,
          sampleScreenPath,
          'CountriesScreen',
          'CountriesPage',
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
            mutated(f, sampleEntityPath, 'CountryName', 'Name'),
        'nested model class renamed': (f) => mutated(
          f,
          sampleNestedModelPath,
          'CountryNameModel',
          'NameModel',
        ),
        'nested mapper extension renamed': (f) => mutated(
          f,
          sampleMapperPath,
          'CountryNameModelMapper',
          'CountryNameMapper',
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
            mutated(f, sampleEntityPath, 'CountryName', 'CountryDto'),
        'Entity suffix': (f) => mutated(
          f,
          sampleEntityPath,
          'abstract class Country ',
          'abstract class CountryEntity ',
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
          'lib/presentation/features/country/country_view_model.dart',
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
          'lib/presentation/features/country/country_screen.dart',
        ),
        'plural repository file': (f) => renamed(
          f,
          sampleRepositoryPath,
          'lib/domain/repositories/country/countries_repository.dart',
        ),
        'plural class outside screen': (f) => mutated(
          f,
          sampleRepositoryPath,
          'CountryRepository',
          'CountriesRepository',
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
          'countryUseCaseProvider',
          'countriesUseCaseProvider',
        ),
        'two providers for one use case': (f) => mutated(
          f,
          sampleDiProvidersPath,
          'final themeUseCaseProvider',
          'final extraCountryUseCaseProvider = Provider<CountryUseCase>((ref) {\n'
              '  return getIt<CountryUseCase>();\n'
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
            mutated(f, sampleApiEndpointPath, 'allCountries', 'countriesAll'),
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
            mutated(f, sampleRoutesPath, 'countriesInHome', 'countriesHome'),
        'path wrong': (f) => mutated(
          f,
          sampleRoutesPath,
          "'/home/countries'",
          "'/countries/home'",
        ),
        'plain constant missing': (f) =>
            mutated(f, sampleRoutesPath, 'countries =', 'countryList ='),
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
          'fetchAllCountries',
          'getCountries',
        ),
        'use case renamed': (f) =>
            mutated(f, sampleUseCasePath, 'fetchAllCountries', 'fetchAll'),
        'repository impl renamed': (f) => mutated(
          f,
          sampleRepositoryImplPath,
          'Future<Result<List<Country>>> fetchAllCountries()',
          'Future<Result<List<Country>>> fetchCountries()',
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
          'Country toEntity()',
          'Country toDomain()',
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
          'CountryName toEntity() {\n    return CountryName(\n      common: common,\n    );\n  }',
          'CountryName toEntity() => CountryName(common: common);',
        ),
        'two toEntity in one extension': (f) => mutated(
          f,
          sampleMapperPath,
          '  Country toEntity() {',
          '  Country toEntity(){return Country();}\n  Country toEntity() {',
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
          '  }) = _Country;',
          '  }) = _Country;\n\n  factory Country.fromJson(Map<String, dynamic> json) => _\$CountryFromJson(json);',
        ),
        'model fromJson deviates': (f) => mutated(
          f,
          sampleModelPath,
          '_\$CountryModelFromJson(json)',
          'CountryModel()',
        ),
        'model without fromJson': (f) => mutated(
          f,
          sampleNestedModelPath,
          'factory CountryNameModel.fromJson(Map<String, dynamic> json) => _\$CountryNameModelFromJson(json);',
          '',
        ),
        'fromJson declared outside models': (f) => mutated(
          f,
          sampleStatePath,
          '  const factory CountryState.error',
          '  factory CountryState.fromJson(Map<String, dynamic> json) => CountryState.data();\n  const factory CountryState.error',
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
          "part 'country_model.freezed.dart';\npart 'country_model.g.dart';",
          "part 'country_model.g.dart';\npart 'country_model.freezed.dart';",
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
          "part 'country_model.freezed.dart';\npart",
          "part 'country_model.freezed.dart';\n\npart",
        ),
        'part with a path': (f) => mutated(
          f,
          sampleStatePath,
          "part 'country_state.freezed.dart';",
          "part 'generated/country_state.freezed.dart';",
        ),
        'part before imports': (f) => {
          ...f,
          sampleEntityPath:
              "part 'country.freezed.dart';\n\nimport 'package:freezed_annotation/freezed_annotation.dart';\n\n${f[sampleEntityPath]!.split("\n\n").skip(2).join("\n\n")}",
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
          '@freezed\nabstract class Country with',
          'abstract class Country with',
        ),
        'not abstract': (f) => mutated(
          f,
          sampleEntityPath,
          'abstract class CountryName',
          'class CountryName',
        ),
        'extra .g.dart part': (f) => mutated(
          f,
          sampleEntityPath,
          "part 'country.freezed.dart';",
          "part 'country.freezed.dart';\npart 'country.g.dart';",
        ),
        'factory not assigned to private class': (f) => mutated(
          f,
          sampleEntityPath,
          '}) = _CountryName;',
          '}) = CountryNameImpl;',
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
          "part 'country_model.g.dart';\n",
          '',
        ),
        'nested field typed as entity': (f) => mutated(
          f,
          sampleModelPath,
          'CountryNameModel? name',
          'CountryName? name',
        ),
        'missing fromJson': (f) => mutated(
          f,
          sampleNestedModelPath,
          'factory CountryNameModel.fromJson(Map<String, dynamic> json) => _\$CountryNameModelFromJson(json);',
          '',
        ),
        'not abstract': (f) => mutated(
          f,
          sampleModelPath,
          'abstract class CountryModel',
          'class CountryModel',
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
          '  const factory CountryState.error',
          '  const factory CountryState.loading() = CountryStateLoading;\n  const factory CountryState.error',
        ),
        'missing @Default([])': (f) =>
            mutated(f, sampleStatePath, '@Default([]) ', ''),
        'wrong list field name': (f) => mutated(
          f,
          sampleStatePath,
          'List<Country> countries',
          'List<Country> items',
        ),
        'extra .g.dart part': (f) => mutated(
          f,
          sampleStatePath,
          "part 'country_state.freezed.dart';",
          "part 'country_state.freezed.dart';\npart 'country_state.g.dart';",
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
          'implements CountryDatasource',
          'extends CountryDatasource',
        ),
        'repository impl without as:': (f) => mutated(
          f,
          sampleRepositoryImplPath,
          '@LazySingleton(as: CountryRepository)',
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
          'class CountryUseCase',
          'abstract class CountryUseCase',
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
          "part 'country_viewmodel.g.dart';",
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
          'const CountriesScreen({super.key});',
          'CountriesScreen({super.key});',
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
          'const CountryItemView({super.key, required this.data});',
          'const CountryItemView({super.key, this.data});',
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
          '@LazySingleton(as: CountryRepository)',
          '@LazySingleton(as: CountryRepository)\n@singleton',
        ),
        'use case without annotation': (f) =>
            mutated(f, sampleUseCasePath, '@lazySingleton\n', ''),
        'datasource remote without as:': (f) => mutated(
          f,
          sampleRemotePath,
          '@LazySingleton(as: CountryDatasource)',
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
          "part 'country.freezed.dart';",
          '',
        ),
        'fromJson without .g.dart': (f) => mutated(
          f,
          sampleNestedModelPath,
          "part 'country_name_model.g.dart';\n",
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
