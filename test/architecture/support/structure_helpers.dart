import 'dart:io';

import 'project.dart';

const diProvidersFile = 'lib/presentation/providers/di_providers.dart';
const apiEndpointFile = 'lib/data/datasource/core/api_endpoint.dart';
const storageKeysFile = 'lib/infrastructure/constants/storage_keys.dart';
const appRoutesFile = 'lib/presentation/router/app_routes.dart';

const translationFiles = [
  'assets/translations/en-US.json',
  'assets/translations/ja-JP.json',
  'assets/translations/vi-VN.json',
];

/// Files of a local feature's presentation dir that docs/conventions.md 2.2
/// explicitly states are UI files outside the feature file set (the only
/// allowed extras in `lib/presentation/<feature>/`).
const localPresentationNonFeatureFiles = {
  'app_theme.dart',
  'app_theme_extension.dart',
};

/// Files of `lib/domain/core/` that are never a feature value enum.
const domainCoreSharedFiles = {
  'lib/domain/core/result.dart',
  'lib/domain/core/app_error.dart',
};

bool isArchitectureTest(String path) => path.startsWith('test/architecture/');

/// Test `.dart` files (generated ones optionally included), excluding
/// `test/architecture/`.
List<String> testDartFiles(ProjectRoot root, {bool includeGenerated = false}) =>
    [
      for (final p in root.testFiles(includeGenerated: includeGenerated))
        if (!isArchitectureTest(p)) p,
    ];

String fileName(String path) => path.split('/').last;

String dirName(String path) {
  final i = path.lastIndexOf('/');
  return i < 0 ? '' : path.substring(0, i);
}

/// `lib/a/b.dart` -> `test/a/b_test.dart`; null if [libPath] is not in lib/.
String? testMirrorOf(String libPath) {
  if (!libPath.startsWith('lib/') || !libPath.endsWith('.dart')) return null;
  return 'test/${libPath.substring(4, libPath.length - 5)}_test.dart';
}

/// `test/a/b_test.dart` -> `lib/a/b.dart`; null if not shaped like a test.
String? libSourceOf(String testPath) {
  if (!testPath.startsWith('test/') || !testPath.endsWith('_test.dart')) {
    return null;
  }
  return 'lib/${testPath.substring(5, testPath.length - '_test.dart'.length)}'
      '.dart';
}

/// `lib/x/y` -> `test/x/y` (for dirs).
String testDirOf(String libDir) => 'test/${libDir.substring(4)}';

/// Concatenation of the non-comment lines of [path].
String codeOf(ProjectRoot root, String path) => [
  for (final l in root.lines(path))
    if (!l.isComment) l.text,
].join('\n');

/// Expected layout of one feature, derived from docs/conventions.md 2.1/2.2.
class FeatureLayout {
  FeatureLayout({
    required this.feature,
    required this.entity,
    required this.screenPlural,
    required this.libFiles,
    required this.testFiles,
    required this.ownedLibDirs,
    required this.nestedModelPattern,
  });

  final Feature feature;

  /// Entity name (null for an API feature with no `*_use_case.dart` yet).
  final String? entity;

  /// Plural used by `{entities}_screen.dart` (API only), as found on disk.
  final String? screenPlural;

  /// Expected lib files (value enum row of the local feature excluded: FIL-09).
  final List<String> libFiles;

  /// Expected test files.
  final List<String> testFiles;

  /// Lib directories that belong to the feature (recursive).
  final List<String> ownedLibDirs;

  /// Nested model files `{entity}_{nested}_model.dart` (API only).
  final RegExp? nestedModelPattern;

  List<String> get expectedFiles => [...libFiles, ...testFiles];
}

/// Builds the [FeatureLayout] of [feature]. For an API feature whose entity
/// cannot be derived (no `*_use_case.dart`), `libFiles`/`testFiles` are empty.
FeatureLayout featureLayout(ProjectRoot root, Feature feature) {
  final f = feature.name;
  final entity = entityName(root, feature);
  if (feature.kind == FeatureKind.local) {
    final lib = [
      'lib/domain/repositories/$f/${f}_repository.dart',
      'lib/domain/use_cases/$f/${f}_use_case.dart',
      'lib/data/repositories/$f/${f}_repository_impl.dart',
      'lib/presentation/$f/${f}_viewmodel.dart',
    ];
    return FeatureLayout(
      feature: feature,
      entity: entity,
      screenPlural: null,
      libFiles: lib,
      testFiles: [
        'test/data/repositories/$f/${f}_repository_impl_test.dart',
        'test/domain/use_cases/$f/${f}_use_case_test.dart',
        'test/presentation/$f/${f}_viewmodel_test.dart',
      ],
      ownedLibDirs: [
        'lib/domain/repositories/$f',
        'lib/domain/use_cases/$f',
        'lib/data/repositories/$f',
        'lib/data/models/$f',
        'lib/presentation/$f',
      ],
      nestedModelPattern: null,
    );
  }

  final presentationDir = 'lib/presentation/features/$f';
  final screens = [
    for (final p in root.dartFilesIn(presentationDir))
      if (dirName(p) == presentationDir && p.endsWith('_screen.dart')) p,
  ];
  String? plural;
  if (screens.isNotEmpty) {
    final base = fileName(screens.first);
    plural = base.substring(0, base.length - '_screen.dart'.length);
  }
  final owned = [
    'lib/domain/repositories/$f',
    'lib/domain/use_cases/$f',
    'lib/data/models/$f',
    'lib/data/datasource/$f',
    'lib/data/repositories/$f',
    presentationDir,
  ];
  if (entity == null) {
    return FeatureLayout(
      feature: feature,
      entity: null,
      screenPlural: plural,
      libFiles: const [],
      testFiles: const [],
      ownedLibDirs: owned,
      nestedModelPattern: null,
    );
  }
  final e = entity;
  final lib = [
    'lib/domain/entities/$e.dart',
    'lib/domain/repositories/$f/${e}_repository.dart',
    'lib/domain/use_cases/$f/${e}_use_case.dart',
    'lib/data/models/$f/${e}_model.dart',
    'lib/data/mappers/${e}_mapper.dart',
    'lib/data/datasource/$f/${e}_datasource.dart',
    'lib/data/datasource/$f/${e}_datasource_remote.dart',
    'lib/data/repositories/$f/${e}_repository_impl.dart',
    '$presentationDir/${e}_state.dart',
    '$presentationDir/${e}_viewmodel.dart',
    '$presentationDir/${plural ?? '{entities}'}_screen.dart',
    '$presentationDir/widget/${e}_item_view.dart',
  ];
  return FeatureLayout(
    feature: feature,
    entity: e,
    screenPlural: plural,
    libFiles: lib,
    testFiles: [
      'test/data/mappers/${e}_mapper_test.dart',
      'test/data/repositories/$f/${e}_repository_impl_test.dart',
      'test/domain/use_cases/$f/${e}_use_case_test.dart',
      'test/presentation/features/$f/${e}_viewmodel_test.dart',
    ],
    ownedLibDirs: owned,
    nestedModelPattern: RegExp(
      '^lib/data/models/$f/${e}_[a-z0-9_]+_model\\.dart\$',
    ),
  );
}

/// Root-relative paths tracked by git in [root], or null when git is missing
/// or [root] is not inside a git repository.
List<String>? gitTrackedFiles(ProjectRoot root) {
  try {
    final result = Process.runSync('git', [
      '-C',
      root.path,
      'ls-files',
      '-z',
    ]);
    if (result.exitCode != 0) return null;
    return (result.stdout as String)
        .split('\u0000')
        .where((s) => s.isNotEmpty)
        .toList();
  } on ProcessException {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Fixture builders (valid minimal projects, package `sample_app`).
// ---------------------------------------------------------------------------

/// Copy of [base] without [keys].
Map<String, String> without(Map<String, String> base, Iterable<String> keys) =>
    {...base}..removeWhere((k, _) => keys.contains(k));

/// Merge of the given maps (later wins).
Map<String, String> merged(Iterable<Map<String, String>> maps) => {
  for (final m in maps) ...m,
};

const _emptyMain = 'void main() {}\n';

/// Valid API feature (default: Product).
Map<String, String> validApiFeature({
  String feature = 'product',
  String entity = 'product',
  String plural = 'products',
  String nested = 'name',
}) {
  final e = entity;
  final f = feature;
  final pascal = snakeToPascal(e);
  return {
    'lib/domain/entities/$e.dart': 'class $pascal {}\n',
    'lib/domain/repositories/$f/${e}_repository.dart':
        'abstract class ${pascal}Repository {}\n',
    'lib/domain/use_cases/$f/${e}_use_case.dart': 'class ${pascal}UseCase {}\n',
    'lib/data/models/$f/${e}_model.dart': 'class ${pascal}Model {}\n',
    'lib/data/models/$f/${e}_${nested}_model.dart':
        'class $pascal${snakeToPascal(nested)}Model {}\n',
    'lib/data/mappers/${e}_mapper.dart': 'class ${pascal}ModelMapper {}\n',
    'lib/data/datasource/$f/${e}_datasource.dart':
        'abstract class ${pascal}Datasource {}\n',
    'lib/data/datasource/$f/${e}_datasource_remote.dart':
        'class ${pascal}DatasourceRemote {}\n',
    'lib/data/repositories/$f/${e}_repository_impl.dart':
        'class ${pascal}RepositoryImpl {}\n',
    'lib/presentation/features/$f/${e}_state.dart': 'class ${pascal}State {}\n',
    'lib/presentation/features/$f/${e}_viewmodel.dart':
        'class ${pascal}Viewmodel {}\n',
    'lib/presentation/features/$f/${plural}_screen.dart':
        'class ${snakeToPascal(plural)}Screen {}\n',
    'lib/presentation/features/$f/widget/${e}_item_view.dart':
        'class ${pascal}ItemView {}\n',
    'test/data/mappers/${e}_mapper_test.dart': _emptyMain,
    'test/data/repositories/$f/${e}_repository_impl_test.dart': _emptyMain,
    'test/domain/use_cases/$f/${e}_use_case_test.dart': _emptyMain,
    'test/presentation/features/$f/${e}_viewmodel_test.dart': _emptyMain,
  };
}

/// Valid local feature (default: Theme with enum `app_theme_mode`).
Map<String, String> validLocalFeature({
  String feature = 'theme',
  String valueType = 'app_theme_mode',
}) {
  final f = feature;
  final pascal = snakeToPascal(f);
  final enumName = snakeToPascal(valueType);
  return {
    'lib/domain/core/$valueType.dart': 'enum $enumName { a }\n',
    'lib/domain/repositories/$f/${f}_repository.dart':
        "import 'package:sample_app/domain/core/$valueType.dart';\n"
        'abstract class ${pascal}Repository {}\n',
    'lib/domain/use_cases/$f/${f}_use_case.dart': 'class ${pascal}UseCase {}\n',
    'lib/data/repositories/$f/${f}_repository_impl.dart':
        'class ${pascal}RepositoryImpl {}\n',
    'lib/presentation/$f/${f}_viewmodel.dart': 'class ${pascal}Viewmodel {}\n',
    'test/data/repositories/$f/${f}_repository_impl_test.dart': _emptyMain,
    'test/domain/use_cases/$f/${f}_use_case_test.dart': _emptyMain,
    'test/presentation/$f/${f}_viewmodel_test.dart': _emptyMain,
  };
}

/// Valid shared files (endpoint, storage keys, routes, DI providers).
Map<String, String> validSharedFiles({
  String useCaseProvider = 'productUseCaseProvider',
}) => {
  apiEndpointFile: 'class APIEndpoint {}\n',
  storageKeysFile: 'class StorageKeys {}\n',
  appRoutesFile: 'class AppRoutes {}\n',
  diProvidersFile: 'final $useCaseProvider = 1;\n',
};

/// Valid translation files with the same flat snake_case keys.
Map<String, String> validTranslations() => {
  for (final path in translationFiles)
    path: '{"home": "Home", "error_retry": "Retry"}\n',
};
