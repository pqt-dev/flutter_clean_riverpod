import 'dart:convert';

import '../support/project.dart';
import '../support/structure_helpers.dart';

// ---------------------------------------------------------------------------
// FIL: file sets, directory names, file locations
// ---------------------------------------------------------------------------

List<Violation> _checkFeatureSet(
  ProjectRoot root,
  FeatureKind kind,
  String ruleId,
) {
  final result = <Violation>[];
  for (final feature in discoverFeatures(root)) {
    if (feature.kind != kind) continue;
    final layout = featureLayout(root, feature);
    final f = feature.name;
    if (layout.entity == null) {
      result.add(
        Violation(
          ruleId,
          'lib/domain/use_cases/$f',
          null,
          'feature $f: no *_use_case.dart, cannot derive entity name',
        ),
      );
      continue;
    }
    final expected = layout.expectedFiles.toSet();
    for (final path in layout.expectedFiles) {
      if (!root.fileExists(path)) {
        result.add(
          Violation(ruleId, path, null, 'feature $f: missing file'),
        );
      }
    }
    final extraBase = <String>[
      ...layout.ownedLibDirs,
      for (final d in layout.ownedLibDirs) testDirOf(d),
    ];
    final seen = <String>{};
    for (final dir in extraBase) {
      final isLibDir = dir.startsWith('lib/');
      for (final path in root.dartFilesIn(dir)) {
        if (!seen.add(path) || expected.contains(path)) continue;
        if (layout.nestedModelPattern?.hasMatch(path) ?? false) continue;
        if (kind == FeatureKind.local &&
            isLibDir &&
            dirName(path) == 'lib/presentation/$f' &&
            localPresentationNonFeatureFiles.contains(fileName(path))) {
          continue;
        }
        result.add(
          Violation(
            ruleId,
            path,
            null,
            'feature $f: unexpected file (not in the feature file set)',
          ),
        );
      }
    }
    if (kind == FeatureKind.local) {
      for (final path in [
        'lib/domain/entities/$f.dart',
        'lib/data/mappers/${f}_mapper.dart',
        'test/data/mappers/${f}_mapper_test.dart',
      ]) {
        if (root.fileExists(path)) {
          result.add(
            Violation(
              ruleId,
              path,
              null,
              'feature $f: local feature must not have this file',
            ),
          );
        }
      }
    }
  }
  return result;
}

/// FIL-01: API feature has exactly the 17 files of table 2.1.
List<Violation> checkFil01(ProjectRoot root) =>
    _checkFeatureSet(root, FeatureKind.api, 'FIL-01');

/// FIL-02: local feature has exactly the 8 files of table 2.2 (the value enum
/// row is checked by FIL-09).
List<Violation> checkFil02(ProjectRoot root) =>
    _checkFeatureSet(root, FeatureKind.local, 'FIL-02');

const _canonicalDirs = {
  'domain': ['core', 'entities', 'repositories', 'use_cases'],
  'data': [
    'core',
    'datasource',
    'failures',
    'mappers',
    'models',
    'repositories',
  ],
};

String _dirKey(String name) {
  var s = name.toLowerCase().replaceAll('_', '');
  if (s.endsWith('ies')) {
    s = '${s.substring(0, s.length - 3)}y';
  } else if (s.endsWith('s')) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}

bool _looksPlural(String name) {
  if (name.endsWith('ies')) return true;
  return name.endsWith('s') &&
      !name.endsWith('ss') &&
      !name.endsWith('us') &&
      !name.endsWith('is');
}

const _featureParents = [
  'domain/repositories',
  'domain/use_cases',
  'data/models',
  'data/datasource',
  'data/repositories',
];

/// FIL-03: canonical directory names (singular/plural) and singular feature
/// directory names.
List<Violation> checkFil03(ProjectRoot root) {
  final result = <Violation>[];
  for (final base in ['lib', 'test']) {
    _canonicalDirs.forEach((layer, names) {
      final byKey = {for (final n in names) _dirKey(n): n};
      for (final dir in root.subdirs('$base/$layer')) {
        final canonical = byKey[_dirKey(dir)];
        if (canonical != null && canonical != dir) {
          result.add(
            Violation(
              'FIL-03',
              '$base/$layer/$dir',
              null,
              'directory must be named `$canonical`',
            ),
          );
        }
      }
    });
    for (final parent in _featureParents) {
      for (final dir in root.subdirs('$base/$parent')) {
        if (dir == 'core') continue;
        if (_looksPlural(dir)) {
          result.add(
            Violation(
              'FIL-03',
              '$base/$parent/$dir',
              null,
              'feature directory must be singular',
            ),
          );
        }
      }
    }
  }
  for (final feature in discoverFeatures(root)) {
    if (feature.kind != FeatureKind.api) continue;
    final dir = 'lib/presentation/features/${feature.name}';
    for (final sub in root.subdirs(dir)) {
      if (sub != 'widget' && _dirKey(sub) == _dirKey('widget')) {
        result.add(
          Violation('FIL-03', '$dir/$sub', null, 'directory must be `widget`'),
        );
      }
    }
  }
  return result;
}

const _featureNameParents = [
  'lib/domain/repositories',
  'lib/data/models',
  'lib/data/datasource',
  'lib/data/repositories',
  'test/domain/use_cases',
  'test/domain/repositories',
  'test/data/models',
  'test/data/datasource',
  'test/data/repositories',
  'test/presentation/features',
];

/// FIL-04: every feature directory name matches a feature (a directory of
/// `lib/domain/use_cases/`) in all the other layers and in `test/`.
/// `core` is exempt everywhere; `widgets` (shared widgets) is exempt only in
/// `test/presentation/features/`.
List<Violation> checkFil04(ProjectRoot root) {
  final features = {for (final f in discoverFeatures(root)) f.name};
  return [
    for (final parent in _featureNameParents)
      for (final dir in root.subdirs(parent))
        if (dir != 'core' &&
            !(parent == 'test/presentation/features' && dir == 'widgets') &&
            !features.contains(dir))
          Violation(
            'FIL-04',
            '$parent/$dir',
            null,
            'directory `$dir` does not match any feature in '
                'lib/domain/use_cases (${features.join(', ')})',
          ),
  ];
}

/// FIL-05: entity + nested entities live in one flat file
/// `lib/domain/entities/{entity}.dart`.
List<Violation> checkFil05(ProjectRoot root) {
  final result = <Violation>[];
  const dir = 'lib/domain/entities';
  for (final sub in root.subdirs(dir)) {
    result.add(
      Violation('FIL-05', '$dir/$sub', null, 'entities must not be in subdirs'),
    );
  }
  for (final feature in discoverFeatures(root)) {
    final entity = entityName(root, feature);
    if (feature.kind != FeatureKind.api || entity == null) continue;
    for (final path in root.dartFilesIn(dir)) {
      if (dirName(path) == dir && fileName(path).startsWith('${entity}_')) {
        result.add(
          Violation(
            'FIL-05',
            path,
            null,
            'nested entity must be in $dir/$entity.dart, not its own file',
          ),
        );
      }
    }
  }
  return result;
}

final _classDecl = RegExp(
  r'^\s*(?:(?:abstract|sealed|final|base|interface|mixin)\s+)*class\s+([A-Za-z]\w*)',
  multiLine: true,
);

/// FIL-06: one class per model file, in `lib/data/models/{feature}/`.
List<Violation> checkFil06(ProjectRoot root) {
  final result = <Violation>[];
  for (final path in root.dartFilesIn('lib/data')) {
    if (!path.endsWith('_model.dart')) continue;
    final rest = path.substring('lib/data/'.length).split('/');
    final ok =
        rest.length == 3 &&
        rest[0] == 'models' &&
        discoverFeatures(root).any((f) => f.name == rest[1]);
    if (!ok) {
      result.add(
        Violation(
          'FIL-06',
          path,
          null,
          'model must be directly in lib/data/models/{feature}/',
        ),
      );
    }
  }
  for (final path in root.dartFilesIn('lib/data/models')) {
    final classes = [
      for (final m in _classDecl.allMatches(codeOf(root, path))) m.group(1)!,
    ];
    if (classes.length != 1) {
      result.add(
        Violation(
          'FIL-06',
          path,
          null,
          'model file must declare exactly one class, found ${classes.length}'
              '${classes.isEmpty ? '' : ': ${classes.join(', ')}'}',
        ),
      );
    }
  }
  return result;
}

/// FIL-07: model-to-entity mappers (files `*_mapper.dart` declaring
/// `toEntity(`) are flat in `lib/data/mappers/`, one file per entity.
List<Violation> checkFil07(ProjectRoot root) {
  final result = <Violation>[];
  const dir = 'lib/data/mappers';
  for (final sub in root.subdirs(dir)) {
    result.add(
      Violation('FIL-07', '$dir/$sub', null, 'mappers must not be in subdirs'),
    );
  }
  for (final path in root.libFiles()) {
    if (path.endsWith('_mapper.dart') &&
        dirName(path) != dir &&
        codeOf(root, path).contains('toEntity(')) {
      result.add(
        Violation('FIL-07', path, null, 'mapper must be in $dir/'),
      );
    }
  }
  for (final feature in discoverFeatures(root)) {
    final entity = entityName(root, feature);
    if (feature.kind != FeatureKind.api || entity == null) continue;
    for (final path in root.dartFilesIn(dir)) {
      final name = fileName(path);
      if (name != '${entity}_mapper.dart' &&
          name.startsWith('${entity}_') &&
          name.endsWith('_mapper.dart')) {
        result.add(
          Violation(
            'FIL-07',
            path,
            null,
            'nested mapper must be in the same file as ${entity}_mapper.dart',
          ),
        );
      }
    }
  }
  return result;
}

/// FIL-08: presentation location (API: `presentation/features/{f}/` with
/// `widget/`; local: `presentation/{f}/`).
List<Violation> checkFil08(ProjectRoot root) {
  final result = <Violation>[];
  for (final feature in discoverFeatures(root)) {
    final f = feature.name;
    if (feature.kind == FeatureKind.api &&
        root.dirExists('lib/presentation/$f')) {
      result.add(
        Violation(
          'FIL-08',
          'lib/presentation/$f',
          null,
          'API feature presentation must be in lib/presentation/features/$f/',
        ),
      );
    }
    if (feature.kind == FeatureKind.local &&
        root.dirExists('lib/presentation/features/$f')) {
      result.add(
        Violation(
          'FIL-08',
          'lib/presentation/features/$f',
          null,
          'local feature presentation must be in lib/presentation/$f/',
        ),
      );
    }
  }
  final apiFeatures = {
    for (final f in discoverFeatures(root))
      if (f.kind == FeatureKind.api) f.name,
  };
  for (final path in root.libFiles('presentation')) {
    if (!path.endsWith('_item_view.dart')) continue;
    final parts = path.split('/');
    final ok =
        parts.length == 6 &&
        parts[2] == 'features' &&
        apiFeatures.contains(parts[3]) &&
        parts[4] == 'widget';
    if (!ok) {
      result.add(
        Violation(
          'FIL-08',
          path,
          null,
          'item view must be in presentation/features/{feature}/widget/',
        ),
      );
    }
  }
  return result;
}

final _enumDecl = RegExp(r'^\s*enum\s+\w+', multiLine: true);

/// FIL-09: the local feature's value enum is in `lib/domain/core/{value}.dart`.
/// The value type is the `lib/domain/core/` file (other than result/app_error)
/// imported by the feature's repository contract.
List<Violation> checkFil09(ProjectRoot root) {
  final result = <Violation>[];
  for (final feature in discoverFeatures(root)) {
    if (feature.kind != FeatureKind.local) continue;
    final f = feature.name;
    final layout = featureLayout(root, feature);
    final repo = 'lib/domain/repositories/$f/${f}_repository.dart';
    if (root.fileExists(repo)) {
      final targets = {
        for (final d in root.directives(repo))
          if (d.targetIn('domain/core') &&
              !domainCoreSharedFiles.contains(d.target))
            d.target!,
      };
      if (targets.isEmpty) {
        result.add(
          Violation(
            'FIL-09',
            repo,
            null,
            'feature $f: repository imports no value enum from lib/domain/core/',
          ),
        );
      }
      for (final t in targets) {
        if (!root.fileExists(t)) {
          result.add(
            Violation('FIL-09', t, null, 'feature $f: value enum file missing'),
          );
        } else if (!_enumDecl.hasMatch(codeOf(root, t))) {
          result.add(
            Violation('FIL-09', t, null, 'feature $f: file declares no enum'),
          );
        }
      }
    }
    for (final path in layout.libFiles) {
      if (root.fileExists(path) && _enumDecl.hasMatch(codeOf(root, path))) {
        result.add(
          Violation(
            'FIL-09',
            path,
            null,
            'feature $f: enum must be declared in lib/domain/core/',
          ),
        );
      }
    }
  }
  return result;
}

final _endpointDecl = RegExp(r'\bclass\s+APIEndpoint\b');
final _storageDecl = RegExp(r'\bclass\s+StorageKeys\b');
final _routesDecl = RegExp(r'\bclass\s+AppRoutes\b');
final _providerDecl = RegExp(r'\b(?:final|const)\s+\w+UseCaseProvider\b');

/// FIL-10: endpoint / storage key / route / DI provider live in their single
/// shared file, and no extra file is created for them.
List<Violation> checkFil10(ProjectRoot root) {
  final result = <Violation>[];
  final features = discoverFeatures(root);
  final hasApi = features.any((f) => f.kind == FeatureKind.api);
  final hasLocal = features.any((f) => f.kind == FeatureKind.local);
  for (final (path, needed) in [
    (apiEndpointFile, hasApi),
    (appRoutesFile, hasApi),
    (storageKeysFile, hasLocal),
    (diProvidersFile, features.isNotEmpty),
  ]) {
    if (needed && !root.fileExists(path)) {
      result.add(Violation('FIL-10', path, null, 'missing shared file'));
    }
  }
  final declarations = [
    (_endpointDecl, apiEndpointFile, 'APIEndpoint'),
    (_storageDecl, storageKeysFile, 'StorageKeys'),
    (_routesDecl, appRoutesFile, 'AppRoutes'),
    (_providerDecl, diProvidersFile, '*UseCaseProvider'),
  ];
  for (final (regex, home, label) in declarations) {
    for (final l in root.linesMatching(
      root.libFiles(),
      regex,
      skip: (p) => p == home,
    )) {
      result.add(
        Violation(
          'FIL-10',
          l.path,
          l.number,
          '$label must be declared only in $home',
        ),
      );
    }
  }
  final filePatterns = [
    (RegExp(r'endpoint'), apiEndpointFile),
    (RegExp(r'storage_key'), storageKeysFile),
    (RegExp(r'(^|_)routes?\.dart$'), appRoutesFile),
    (RegExp(r'di_provider'), diProvidersFile),
  ];
  for (final path in root.libFiles()) {
    for (final (pattern, home) in filePatterns) {
      if (path != home && pattern.hasMatch(fileName(path))) {
        result.add(
          Violation(
            'FIL-10',
            path,
            null,
            'do not create a new file; use $home',
          ),
        );
      }
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
// TST / NAM-12: tests
// ---------------------------------------------------------------------------

/// TST-01: every `test/**/*_test.dart` mirrors an existing `lib/**/*.dart`.
List<Violation> checkTst01(ProjectRoot root) {
  final result = <Violation>[];
  for (final path in testDartFiles(root)) {
    final source = libSourceOf(path);
    if (source == null) {
      result.add(
        Violation(
          'TST-01',
          path,
          null,
          'test file name must end with _test.dart',
        ),
      );
    } else if (!root.fileExists(source)) {
      result.add(
        Violation(
          'TST-01',
          path,
          null,
          'does not mirror a lib file (expected $source)',
        ),
      );
    }
  }
  return result;
}

/// TST-02: API feature has 4 test files, local feature has 3 (mirror paths).
List<Violation> checkTst02(ProjectRoot root) {
  final result = <Violation>[];
  for (final feature in discoverFeatures(root)) {
    final layout = featureLayout(root, feature);
    for (final path in layout.testFiles) {
      if (!root.fileExists(path)) {
        result.add(
          Violation(
            'TST-02',
            path,
            null,
            'feature ${feature.name}: missing test file',
          ),
        );
      }
    }
  }
  return result;
}

final _mainDecl = RegExp(r'^void main\(\s*\)', multiLine: true);
final _generateMocks = RegExp(r'@GenerateNiceMocks\(');
final _generateMocksAboveMain = RegExp(
  r'@GenerateNiceMocks\(\[[\s\S]*?\]\)\s*void main\(\s*\)',
);

/// TST-03: `void main()` present; mocks via `@GenerateNiceMocks` right above
/// `main` and import of `{file}_test.mocks.dart`.
List<Violation> checkTst03(ProjectRoot root) {
  final result = <Violation>[];
  for (final path in testDartFiles(root)) {
    final code = codeOf(root, path);
    if (!_mainDecl.hasMatch(code)) {
      result.add(Violation('TST-03', path, null, 'missing `void main()`'));
    }
    final base = fileName(path).replaceAll(RegExp(r'\.dart$'), '');
    final mockImports = [
      for (final d in root.directives(path))
        if (d.uri.endsWith('.mocks.dart')) d,
    ];
    final hasAnnotation = _generateMocks.hasMatch(code);
    if (!hasAnnotation && mockImports.isEmpty) continue;
    if (!hasAnnotation) {
      result.add(
        Violation(
          'TST-03',
          path,
          mockImports.first.number,
          'imports mocks but has no @GenerateNiceMocks',
        ),
      );
    } else if (!_generateMocksAboveMain.hasMatch(code)) {
      result.add(
        Violation(
          'TST-03',
          path,
          null,
          '@GenerateNiceMocks must be right above `void main()`',
        ),
      );
    }
    final own = '$base.mocks.dart';
    if (!mockImports.any((d) => fileName(d.uri) == own)) {
      result.add(
        Violation('TST-03', path, null, "missing import of '$own'"),
      );
    }
    for (final d in mockImports) {
      if (fileName(d.uri) != own) {
        result.add(
          Violation(
            'TST-03',
            path,
            d.number,
            'unexpected mocks import: ${d.uri}',
          ),
        );
      }
    }
  }
  return result;
}

final _mockSpecRegex = RegExp(r'MockSpec<\s*([A-Za-z_]\w*)');
final _mockIdentRegex = RegExp(r'\bMock[A-Z]\w*');

/// NAM-12: test file = source + `_test`; mock file `{x}_test.mocks.dart`;
/// mock class `Mock{Class}`.
List<Violation> checkNam12(ProjectRoot root) {
  final result = <Violation>[];
  for (final path in testDartFiles(root, includeGenerated: true)) {
    final name = fileName(path);
    if (name.endsWith('.mocks.dart')) {
      if (!name.endsWith('_test.mocks.dart')) {
        result.add(
          Violation(
            'NAM-12',
            path,
            null,
            'mock file must be {x}_test.mocks.dart',
          ),
        );
      } else if (!root.fileExists(
        '${path.substring(0, path.length - '.mocks.dart'.length)}.dart',
      )) {
        result.add(
          Violation(
            'NAM-12',
            path,
            null,
            'mock file has no matching test file',
          ),
        );
      }
      continue;
    }
    if (generatedSuffixes.any(name.endsWith)) continue;
    if (!name.endsWith('_test.dart')) {
      result.add(
        Violation(
          'NAM-12',
          path,
          null,
          'test file name must end with _test.dart',
        ),
      );
      continue;
    }
    final code = codeOf(root, path);
    final specs = {
      for (final m in _mockSpecRegex.allMatches(code)) 'Mock${m.group(1)}',
    };
    final lines = root.lines(path).where((l) => !l.isComment);
    for (final l in lines) {
      for (final m in _mockIdentRegex.allMatches(l.text)) {
        final ident = m.group(0)!;
        if (ident == 'MockSpec' || specs.contains(ident)) continue;
        result.add(
          Violation(
            'NAM-12',
            path,
            l.number,
            'mock class `$ident` must be Mock{Class} of a MockSpec<Class>',
          ),
        );
      }
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
// L10N / NAM-14
// ---------------------------------------------------------------------------

final _snakeCase = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');

/// Decodes a translation file; null when missing or not a JSON object.
Map<String, dynamic>? _readTranslation(ProjectRoot root, String path) {
  if (!root.fileExists(path)) return null;
  try {
    final decoded = jsonDecode(root.lines(path).map((l) => l.text).join('\n'));
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

/// NAM-14: l10n keys are flat and snake_case.
List<Violation> checkNam14(ProjectRoot root) {
  final result = <Violation>[];
  for (final path in translationFiles) {
    final data = _readTranslation(root, path);
    if (data == null) continue;
    data.forEach((key, value) {
      if (!_snakeCase.hasMatch(key)) {
        result.add(
          Violation('NAM-14', path, null, 'key `$key` must be snake_case'),
        );
      }
      if (value is Map || value is List) {
        result.add(
          Violation('NAM-14', path, null, 'key `$key` must not be nested'),
        );
      }
    });
  }
  return result;
}

/// L10N-02: the 3 translation files exist, are valid JSON objects and have the
/// same key set.
List<Violation> checkL10n02(ProjectRoot root) {
  final result = <Violation>[];
  final keys = <String, Set<String>>{};
  for (final path in translationFiles) {
    if (!root.fileExists(path)) {
      result.add(Violation('L10N-02', path, null, 'translation file missing'));
      continue;
    }
    final data = _readTranslation(root, path);
    if (data == null) {
      result.add(
        Violation('L10N-02', path, null, 'not a valid JSON object'),
      );
      continue;
    }
    keys[path] = data.keys.toSet();
  }
  if (keys.length > 1) {
    final all = keys.values.expand((k) => k).toSet();
    keys.forEach((path, own) {
      for (final key in (all.difference(own).toList()..sort())) {
        result.add(
          Violation(
            'L10N-02',
            path,
            null,
            'missing key `$key` (present elsewhere)',
          ),
        );
      }
    });
  }
  return result;
}

final _l10nUsage = RegExp(r'\.tr\(|\bLocaleKeys\b');

/// L10N-03: `.tr()` and `LocaleKeys` only in `lib/presentation/`.
List<Violation> checkL10n03(ProjectRoot root) => [
  for (final l in root.linesMatching(
    root.libFiles(),
    _l10nUsage,
    skip: (p) => p.startsWith('lib/presentation/'),
  ))
    Violation(
      'L10N-03',
      l.path,
      l.number,
      '.tr()/LocaleKeys only allowed in lib/presentation: ${l.text.trim()}',
    ),
];

// ---------------------------------------------------------------------------
// GEN
// ---------------------------------------------------------------------------

/// GEN-01 (pure): no generated file is tracked by git.
List<Violation> checkGen01(List<String> trackedFiles) => [
  for (final path in trackedFiles)
    if (generatedSuffixes.any(path.endsWith))
      Violation('GEN-01', path, null, 'generated file must not be committed'),
];

/// GEN-01 on a project: uses `git ls-files`; empty when git is unavailable or
/// [root] is not a git repository.
List<Violation> checkGen01OnProject(ProjectRoot root) {
  final tracked = gitTrackedFiles(root);
  return tracked == null ? const [] : checkGen01(tracked);
}
