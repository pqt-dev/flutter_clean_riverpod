import '../support/project.dart';
import '../support/source_helpers.dart';
import 'layer_checks.dart';

const apiEndpointPath = 'lib/data/datasource/core/api_endpoint.dart';
const appRoutesPath = 'lib/presentation/router/app_routes.dart';

List<FeatureContext> _apiContexts(ProjectRoot root) => [
  for (final c in featureContexts(root))
    if (c.isApi) c,
];

/// Collects violations of one rule.
class _Out {
  _Out(this.id);

  final String id;
  final List<Violation> list = [];

  void add(String path, int? line, String message) =>
      list.add(Violation(id, path, line, message));
}

/// Declared type names of [path] (empty if the file is missing).
List<String> _typeNames(ProjectRoot root, String path) => root.fileExists(path)
    ? declaredTypes(codeText(root, path)).map((t) => t.name).toList()
    : [];

String _usesClass(String name) =>
    r'^\s*@lazySingleton\s+class\s+' + name + r'\b';

// ---------------------------------------------------------------------------
// NAM
// ---------------------------------------------------------------------------

/// NAM-03: class names match the "Class" column of tables 2.1/2.2 (fixed
/// suffixes).
List<Violation> checkNam03(ProjectRoot root) {
  final out = _Out('NAM-03');
  for (final c in featureContexts(root)) {
    void expectType(String path, String name) {
      if (!root.fileExists(path)) return;
      final names = _typeNames(root, path);
      if (!names.contains(name)) {
        out.add(
          path,
          null,
          'expected class/extension $name, found: ${names.join(', ')}',
        );
      }
    }

    final e = c.entityPascal;
    expectType(c.repositoryPath, '${e}Repository');
    expectType(c.repositoryImplPath, '${e}RepositoryImpl');
    expectType(c.viewmodelPath, '${e}Viewmodel');
    expectType(c.useCasePath, '${e}UseCase');
    if (c.isApi) {
      expectType(c.entityPath, e);
      expectType(c.modelPath, '${e}Model');
      expectType(c.mapperPath, '${e}ModelMapper');
      expectType(c.datasourcePath, '${e}Datasource');
      expectType(c.remotePath, '${e}DatasourceRemote');
      expectType(c.statePath, '${e}State');
      for (final p in c.screenPaths) {
        expectType(p, snakeToPascal(stem(p)));
      }
      for (final p in c.itemViewPaths) {
        expectType(p, snakeToPascal(stem(p)));
      }
    }
  }
  return out.list;
}

/// NAM-04: nested entity `{Entity}{Nested}`, nested model
/// `{Entity}{Nested}Model`, nested mapper `{Entity}{Nested}ModelMapper`.
List<Violation> checkNam04(ProjectRoot root) {
  final out = _Out('NAM-04');
  for (final c in _apiContexts(root)) {
    final e = c.entityPascal;
    if (root.fileExists(c.entityPath)) {
      for (final t in declaredTypes(codeText(root, c.entityPath))) {
        if (t.name == e) continue;
        final rest = t.name.startsWith(e) ? t.name.substring(e.length) : '';
        if (rest.isEmpty || rest[0] != rest[0].toUpperCase()) {
          out.add(
            c.entityPath,
            t.line,
            'nested entity must be $e<Nested>, found ${t.name}',
          );
        }
      }
    }
    for (final p in c.modelPaths) {
      if (p == c.modelPath) continue;
      final s = stem(p);
      final expected = snakeToPascal(s);
      if (!s.startsWith('${c.entity}_') || !s.endsWith('_model')) {
        out.add(
          p,
          null,
          'nested model file must be ${c.entity}_<nested>_model.dart',
        );
      }
      if (!_typeNames(root, p).contains(expected)) {
        out.add(
          p,
          null,
          'nested model must be named $expected, found: '
          '${_typeNames(root, p).join(', ')}',
        );
      }
    }
    if (root.fileExists(c.mapperPath)) {
      for (final ext in extensionDecls(codeText(root, c.mapperPath))) {
        final okOn =
            ext.onType.startsWith(e) &&
            ext.onType.endsWith('Model') &&
            ext.onType != e;
        if (!okOn || ext.name != '${ext.onType}Mapper') {
          out.add(
            c.mapperPath,
            ext.line,
            'mapper extension must be <Entity><Nested>ModelMapper on '
            '<Entity><Nested>Model, found ${ext.name} on ${ext.onType}',
          );
        }
      }
    }
  }
  return out.list;
}

/// NAM-05: entities have no `Entity`/`Dto` suffix.
List<Violation> checkNam05(ProjectRoot root) {
  final out = _Out('NAM-05');
  final suffix = RegExp(r'(Entity|Dto)$');
  final fileSuffix = RegExp(r'_(entity|dto)$');
  for (final path in root.libFiles('domain/entities')) {
    if (fileSuffix.hasMatch(stem(path))) {
      out.add(path, null, 'entity file must not end with _entity/_dto');
    }
    for (final t in declaredTypes(codeText(root, path))) {
      if (suffix.hasMatch(t.name)) {
        out.add(
          path,
          t.line,
          'entity must not have Entity/Dto suffix: ${t.name}',
        );
      }
    }
  }
  return out.list;
}

/// NAM-06: `Viewmodel` (lowercase m), never `ViewModel`.
List<Violation> checkNam06(ProjectRoot root) {
  final out = _Out('NAM-06');
  final wrong = RegExp(r'ViewModel');
  for (final path in root.libFiles()) {
    if (path.contains('view_model')) {
      out.add(path, null, 'use viewmodel in file names, not view_model');
    }
  }
  for (final l in root.linesMatching(root.libFiles(), wrong)) {
    out.add(
      l.path,
      l.number,
      'write Viewmodel (lowercase m), not ViewModel: ${l.text.trim()}',
    );
  }
  return out.list;
}

/// NAM-07: screens are plural, every other API feature file is singular.
List<Violation> checkNam07(ProjectRoot root) {
  final out = _Out('NAM-07');
  for (final c in _apiContexts(root)) {
    final plural = c.plural;
    if (plural == null) continue;
    if (plural == c.entity) {
      for (final p in c.screenPaths) {
        out.add(p, null, 'screen name must be plural, found ${c.entity}');
      }
      continue;
    }
    final dirs = [
      'lib/domain/repositories/${c.name}',
      c.useCaseDir,
      c.modelDir,
      c.datasourceDir,
      'lib/data/repositories/${c.name}',
      c.presentationDir,
    ];
    for (final dir in dirs) {
      for (final p in root.dartFilesIn(dir)) {
        if (p.endsWith('_screen.dart')) continue;
        final s = stem(p);
        if (s != c.entity && !s.startsWith('${c.entity}_')) {
          out.add(p, null, 'file name must start with singular ${c.entity}');
        }
      }
    }
    for (final p in ['lib/domain/entities/$plural.dart']) {
      if (root.fileExists(p)) out.add(p, null, 'entity file must be singular');
    }
    if (root.fileExists('lib/data/mappers/${plural}_mapper.dart')) {
      out.add(
        'lib/data/mappers/${plural}_mapper.dart',
        null,
        'mapper file must be singular',
      );
    }
    final pluralPascal = c.pluralPascal!;
    for (final p in c.featureFiles) {
      if (p.endsWith('_screen.dart')) continue;
      for (final t in declaredTypes(codeText(root, p))) {
        if (t.name.startsWith(pluralPascal)) {
          out.add(
            p,
            t.line,
            'only Screen is plural; ${t.name} must use singular ${c.entityPascal}',
          );
        }
      }
    }
  }
  return out.list;
}

/// NAM-08: each use case has exactly one provider `{entity}UseCaseProvider`
/// in di_providers.dart.
List<Violation> checkNam08(ProjectRoot root) {
  final out = _Out('NAM-08');
  final contexts = featureContexts(root);
  if (contexts.isEmpty) return out.list;
  if (!root.fileExists(diProvidersPath)) {
    out.add(diProvidersPath, null, 'di_providers.dart is missing');
    return out.list;
  }
  final text = codeText(root, diProvidersPath);
  final providers = [
    for (final m in RegExp(
      r'final\s+(\w+)\s*=\s*Provider<(\w+)>',
    ).allMatches(text))
      (name: m.group(1)!, type: m.group(2)!, line: lineOf(text, m.start)),
  ];
  for (final c in contexts) {
    for (final p in c.useCasePaths) {
      final cls = snakeToPascal(stem(p));
      final expected = '${lowerFirst(cls)}Provider';
      final matching = providers.where((x) => x.type == cls).toList();
      if (matching.length != 1) {
        out.add(
          diProvidersPath,
          matching.isEmpty ? null : matching[1].line,
          'use case $cls must have exactly one provider, found '
          '${matching.length}',
        );
      } else if (matching.single.name != expected) {
        out.add(
          diProvidersPath,
          matching.single.line,
          'provider of $cls must be named $expected, found '
          '${matching.single.name}',
        );
      }
    }
  }
  return out.list;
}

/// NAM-09: `APIEndpoint.all{Entities}` in api_endpoint.dart.
List<Violation> checkNam09(ProjectRoot root) {
  final out = _Out('NAM-09');
  final contexts = [
    for (final c in _apiContexts(root))
      if (c.plural != null) c,
  ];
  if (contexts.isEmpty) return out.list;
  if (!root.fileExists(apiEndpointPath)) {
    out.add(apiEndpointPath, null, 'api_endpoint.dart is missing');
    return out.list;
  }
  final text = codeText(root, apiEndpointPath);
  if (!RegExp(r'\bclass\s+APIEndpoint\b').hasMatch(text)) {
    out.add(apiEndpointPath, null, 'class must be named APIEndpoint');
  }
  for (final c in contexts) {
    final name = 'all${c.pluralPascal}';
    if (!RegExp(
      r'static\s+const\s+(?:String\s+)?' + name + r'\s*=',
    ).hasMatch(text)) {
      out.add(apiEndpointPath, null, 'missing APIEndpoint.$name');
    }
  }
  return out.list;
}

/// NAM-10: route constants `{entities}` and `{entities}InHome`.
List<Violation> checkNam10(ProjectRoot root) {
  final out = _Out('NAM-10');
  final contexts = [
    for (final c in _apiContexts(root))
      if (c.plural != null) c,
  ];
  if (contexts.isEmpty) return out.list;
  if (!root.fileExists(appRoutesPath)) {
    out.add(appRoutesPath, null, 'app_routes.dart is missing');
    return out.list;
  }
  final text = codeText(root, appRoutesPath);
  for (final c in contexts) {
    final id = c.pluralCamel!;
    final path = c.plural!;
    final plain = RegExp(
      r'static\s+const\s+(?:String\s+)?' + id + r"\s*=\s*'/" + path + r"'\s*;",
    );
    final inHome = RegExp(
      r'static\s+const\s+(?:String\s+)?' +
          id +
          r"InHome\s*=\s*'/home/" +
          path +
          r"'\s*;",
    );
    if (!plain.hasMatch(text)) {
      out.add(appRoutesPath, null, "expected AppRoutes.$id = '/$path'");
    }
    if (!inHome.hasMatch(text)) {
      out.add(
        appRoutesPath,
        null,
        "expected AppRoutes.${id}InHome = '/home/$path'",
      );
    }
  }
  return out.list;
}

// ---------------------------------------------------------------------------
// MET
// ---------------------------------------------------------------------------

/// MET-01: list method is `fetchAll{Entities}` in datasource (abstract and
/// remote), repository (abstract and impl) and use case.
List<Violation> checkMet01(ProjectRoot root) {
  final out = _Out('MET-01');
  final listMethod = RegExp(r'Future<Result<List<\w+>>>\s+(\w+)\s*\(');
  for (final c in _apiContexts(root)) {
    final plural = c.pluralPascal;
    if (plural == null) continue;
    final name = 'fetchAll$plural';
    for (final path in [
      c.datasourcePath,
      c.remotePath,
      c.repositoryPath,
      c.repositoryImplPath,
      c.useCasePath,
    ]) {
      if (!root.fileExists(path)) continue;
      final text = codeText(root, path);
      if (!RegExp('\\b$name\\s*\\(').hasMatch(text)) {
        out.add(path, null, 'missing list method $name()');
      }
      for (final m in listMethod.allMatches(text)) {
        if (m.group(1) != name) {
          out.add(
            path,
            lineOf(text, m.start),
            'list method must be $name, found ${m.group(1)}',
          );
        }
      }
    }
  }
  return out.list;
}

/// MET-05: mapper extensions have exactly one `{Entity} toEntity()` with body
/// `return {Entity}(...)`; fields map by same name, nested models via
/// `field?.toEntity()`.
List<Violation> checkMet05(ProjectRoot root) {
  final out = _Out('MET-05');
  for (final c in _apiContexts(root)) {
    if (!root.fileExists(c.mapperPath)) continue;
    final modelFields = <String, List<Param>>{};
    for (final p in c.modelPaths) {
      final text = codeText(root, p);
      for (final t in declaredTypes(text)) {
        final params = factoryParams(text, t.name);
        if (params != null) modelFields[t.name] = params;
      }
    }
    final text = codeText(root, c.mapperPath);
    for (final ext in extensionDecls(text)) {
      final decls = RegExp(
        r'(\w+)\s+toEntity\s*\(([^)]*)\)\s*(\{|=>)',
      ).allMatches(ext.body).toList();
      if (decls.length != 1) {
        out.add(
          c.mapperPath,
          ext.line,
          '${ext.name} must have exactly one toEntity(), found ${decls.length}',
        );
        continue;
      }
      final m = decls.single;
      final returnType = m.group(1)!;
      final expected = ext.onType.endsWith('Model')
          ? ext.onType.substring(0, ext.onType.length - 5)
          : ext.onType;
      if (m.group(2)!.trim().isNotEmpty) {
        out.add(c.mapperPath, ext.line, '${ext.name}.toEntity() takes no args');
      }
      if (returnType != expected) {
        out.add(
          c.mapperPath,
          ext.line,
          '${ext.name}.toEntity() must return $expected, found $returnType',
        );
      }
      if (m.group(3) != '{' ||
          !RegExp(
            r'return\s+' + expected + r'\s*\(',
          ).hasMatch(ext.body)) {
        out.add(
          c.mapperPath,
          ext.line,
          '${ext.name}.toEntity() body must be `return $expected(...)`',
        );
        continue;
      }
      for (final f in modelFields[ext.onType] ?? <Param>[]) {
        final nested = modelFields.containsKey(f.type.replaceAll('?', ''));
        final pattern = nested
            ? RegExp('\\b${f.name}\\s*:\\s*${f.name}\\s*\\?\\.toEntity\\(\\)')
            : RegExp('\\b${f.name}\\s*:\\s*${f.name}\\s*[,)]');
        if (!pattern.hasMatch(ext.body)) {
          out.add(
            c.mapperPath,
            ext.line,
            nested
                ? '${ext.name}: nested field ${f.name} must be '
                      '${f.name}: ${f.name}?.toEntity()'
                : '${ext.name}: field ${f.name} must be mapped as '
                      '${f.name}: ${f.name}',
          );
        }
      }
    }
  }
  return out.list;
}

/// MET-06: `fromJson` only in Models, in the exact generated form; entities
/// have no `fromJson`/`toJson`.
List<Violation> checkMet06(ProjectRoot root) {
  final out = _Out('MET-06');
  for (final l in root.linesMatching(
    root.libFiles('domain/entities'),
    RegExp(r'\b(fromJson|toJson)\b'),
  )) {
    out.add(
      l.path,
      l.number,
      'entity must not have fromJson/toJson: ${l.text.trim()}',
    );
  }
  for (final l in root.linesMatching(
    root.libFiles(),
    RegExp(r'factory\s+\w+\s*\.\s*fromJson\b'),
    skip: (p) => p.startsWith('lib/data/models/'),
  )) {
    out.add(
      l.path,
      l.number,
      'fromJson is only allowed in a Model: ${l.text.trim()}',
    );
  }
  for (final c in _apiContexts(root)) {
    for (final p in c.modelPaths) {
      final text = codeText(root, p);
      for (final t in declaredTypes(text)) {
        if (t.kind != 'class') continue;
        final n = t.name;
        final exact = RegExp(
          r'factory\s+' +
              n +
              r'\.fromJson\(\s*Map<String,\s*dynamic>\s+json\s*\)\s*=>\s*_\$' +
              n +
              r'FromJson\(json\)\s*;',
        );
        if (!exact.hasMatch(text)) {
          out.add(
            p,
            t.line,
            'missing `factory $n.fromJson(Map<String, dynamic> json) => '
            '_\$${n}FromJson(json);`',
          );
        }
      }
    }
  }
  return out.list;
}

// ---------------------------------------------------------------------------
// IMP
// ---------------------------------------------------------------------------

/// IMP-05: `part` after the imports, one blank line, bare file names,
/// `.freezed.dart` before `.g.dart`.
List<Violation> checkImp05(ProjectRoot root) {
  final out = _Out('IMP-05');
  for (final path in root.libFiles()) {
    final parts = partDirectives(root, path);
    if (parts.isEmpty) continue;
    final s = stem(path);
    for (final part in parts) {
      if (part.uri != '$s.freezed.dart' && part.uri != '$s.g.dart') {
        out.add(
          path,
          part.line,
          "part must be '$s.freezed.dart' or '$s.g.dart' (file name only), "
          'found ${part.uri}',
        );
      }
    }
    final freezedIndex = parts.indexWhere(
      (p) => p.uri.endsWith('.freezed.dart'),
    );
    final gIndex = parts.indexWhere((p) => p.uri.endsWith('.g.dart'));
    if (freezedIndex >= 0 && gIndex >= 0 && freezedIndex > gIndex) {
      out.add(
        path,
        parts[gIndex].line,
        '.freezed.dart part must come before .g.dart',
      );
    }
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].line != parts[i - 1].line + 1) {
        out.add(path, parts[i].line, 'part directives must be contiguous');
      }
    }
    final imports = root.directives(path);
    if (imports.isEmpty) continue;
    final lastImport = imports
        .map((d) => d.number)
        .reduce(
          (a, b) => a > b ? a : b,
        );
    final first = parts.first.line;
    if (first < lastImport) {
      out.add(path, first, 'part must come after the import block');
      continue;
    }
    final lines = root.lines(path);
    final blankBetween = first - lastImport - 1;
    final isBlank = blankBetween == 1 && lines[lastImport].text.trim().isEmpty;
    if (!isBlank) {
      out.add(
        path,
        first,
        'exactly one blank line required between imports and part',
      );
    }
  }
  return out.list;
}

// ---------------------------------------------------------------------------
// CLS
// ---------------------------------------------------------------------------

String _freezedAbstract(String n) =>
    r'@freezed\s+abstract\s+class\s+' + n + r'\s+with\s+_\$' + n + r'\s*\{';

/// Reports when the `part` set of [path] is not exactly [expected].
void _expectParts(
  ProjectRoot root,
  _Out out,
  String path,
  List<String> expected,
) {
  final uris = partDirectives(root, path).map((p) => p.uri).toList();
  if (uris.length != expected.length || !expected.every(uris.contains)) {
    out.add(
      path,
      null,
      'parts must be exactly ${expected.join(', ')}, found '
      '${uris.isEmpty ? 'none' : uris.join(', ')}',
    );
  }
}

/// CLS-01: entities are `@freezed abstract class X with _$X` with
/// `const factory X({...}) = _X;`, only the `.freezed.dart` part, no fromJson.
List<Violation> checkCls01(ProjectRoot root) {
  final out = _Out('CLS-01');
  for (final c in _apiContexts(root)) {
    final path = c.entityPath;
    if (!root.fileExists(path)) continue;
    final text = codeText(root, path);
    for (final t in declaredTypes(text)) {
      final n = t.name;
      if (!RegExp(_freezedAbstract(n)).hasMatch(text)) {
        out.add(
          path,
          t.line,
          'entity $n must be `@freezed abstract class $n with _\$$n`',
        );
      }
      if (!RegExp(
        r'const\s+factory\s+' +
            n +
            r'\s*\(\s*\{[\s\S]*?\}\s*\)\s*=\s*_' +
            n +
            r'\s*;',
      ).hasMatch(text)) {
        out.add(
          path,
          t.line,
          'entity $n needs `const factory $n({...}) = _$n;`',
        );
      }
    }
    _expectParts(root, out, path, ['${c.entity}.freezed.dart']);
    if (RegExp(r'\bfromJson\b').hasMatch(text)) {
      out.add(path, null, 'entity must not have fromJson');
    }
  }
  return out.list;
}

/// CLS-02: models are `@freezed abstract class XModel with _$XModel`, two
/// parts, `fromJson` factory, nested fields typed as models.
List<Violation> checkCls02(ProjectRoot root) {
  final out = _Out('CLS-02');
  for (final c in _apiContexts(root)) {
    final entityTypes = {..._typeNames(root, c.entityPath)};
    for (final path in c.modelPaths) {
      final text = codeText(root, path);
      for (final t in declaredTypes(text)) {
        final n = t.name;
        if (!RegExp(_freezedAbstract(n)).hasMatch(text)) {
          out.add(
            path,
            t.line,
            'model $n must be `@freezed abstract class $n with _\$$n`',
          );
        }
        if (!RegExp(
          r'const\s+factory\s+' +
              n +
              r'\s*\(\s*\{[\s\S]*?\}\s*\)\s*=\s*_' +
              n +
              r'\s*;',
        ).hasMatch(text)) {
          out.add(
            path,
            t.line,
            'model $n needs `const factory $n({...}) = _$n;`',
          );
        }
        if (!RegExp(r'factory\s+' + n + r'\.fromJson\(').hasMatch(text)) {
          out.add(path, t.line, 'model $n needs a fromJson factory');
        }
        for (final param in factoryParams(text, n) ?? <Param>[]) {
          final used = RegExp(
            r'\w+',
          ).allMatches(param.type).map((m) => m.group(0));
          for (final id in used) {
            if (entityTypes.contains(id)) {
              out.add(
                path,
                t.line,
                'field ${param.name} of $n uses entity type $id; '
                'use the nested model instead',
              );
            }
          }
        }
      }
      final s = stem(path);
      _expectParts(root, out, path, ['$s.freezed.dart', '$s.g.dart']);
    }
  }
  return out.list;
}

/// CLS-03: state is `@freezed sealed class XState` with exactly the `data`
/// and `error` factories, only the `.freezed.dart` part.
List<Violation> checkCls03(ProjectRoot root) {
  final out = _Out('CLS-03');
  for (final c in _apiContexts(root)) {
    final path = c.statePath;
    if (!root.fileExists(path)) continue;
    final text = codeText(root, path);
    final n = '${c.entityPascal}State';
    final field = c.pluralCamel ?? r'\w+';
    if (!RegExp(
      r'@freezed\s+sealed\s+class\s+' + n + r'\s+with\s+_\$' + n + r'\s*\{',
    ).hasMatch(text)) {
      out.add(
        path,
        null,
        'state must be `@freezed sealed class $n with _\$$n`',
      );
    }
    final dataFactory = RegExp(
      r'const\s+factory\s+' +
          n +
          r'\.data\(\s*\{\s*@Default\(\[\]\)\s+List<' +
          c.entityPascal +
          r'>\s+' +
          field +
          r'\s*,?\s*\}\s*\)\s*=\s*' +
          n +
          r'Data\s*;',
    );
    final errorFactory = RegExp(
      r'const\s+factory\s+' +
          n +
          r'\.error\(\s*AppError\s+error\s*,?\s*\)\s*=\s*' +
          n +
          r'Error\s*;',
    );
    if (!dataFactory.hasMatch(text)) {
      out.add(
        path,
        null,
        'missing `const factory $n.data({@Default([]) List<${c.entityPascal}> '
        '${c.pluralCamel ?? 'entities'}}) = ${n}Data;`',
      );
    }
    if (!errorFactory.hasMatch(text)) {
      out.add(
        path,
        null,
        'missing `const factory $n.error(AppError error) = ${n}Error;`',
      );
    }
    final factories = RegExp(r'const\s+factory\b').allMatches(text).length;
    if (factories != 2) {
      out.add(
        path,
        null,
        'state must have exactly 2 factories, found $factories',
      );
    }
    _expectParts(root, out, path, ['${stem(path)}.freezed.dart']);
  }
  return out.list;
}

/// CLS-05: datasource remote and repository impl are
/// `@LazySingleton(as: <abstract>) class X implements <abstract>`.
List<Violation> checkCls05(ProjectRoot root) {
  final out = _Out('CLS-05');
  for (final c in featureContexts(root)) {
    final e = c.entityPascal;
    final targets = [
      if (c.isApi) (c.remotePath, '${e}DatasourceRemote', '${e}Datasource'),
      (c.repositoryImplPath, '${e}RepositoryImpl', '${e}Repository'),
    ];
    for (final (path, cls, abstract) in targets) {
      if (!root.fileExists(path)) continue;
      final text = codeText(root, path);
      final ok = RegExp(
        r'@LazySingleton\(\s*as:\s*' +
            abstract +
            r'\s*\)\s+class\s+' +
            cls +
            r'\s+implements\s+' +
            abstract +
            r'\b',
      ).hasMatch(text);
      if (!ok) {
        out.add(
          path,
          null,
          'expected `@LazySingleton(as: $abstract) class $cls implements '
          '$abstract`',
        );
      }
    }
  }
  return out.list;
}

/// CLS-06: use case is `@lazySingleton class XUseCase` (not abstract).
List<Violation> checkCls06(ProjectRoot root) {
  final out = _Out('CLS-06');
  for (final c in featureContexts(root)) {
    for (final path in c.useCasePaths) {
      final cls = snakeToPascal(stem(path));
      if (!RegExp(
        _usesClass(cls),
        multiLine: true,
      ).hasMatch(codeText(root, path))) {
        out.add(
          path,
          null,
          'expected `@lazySingleton class $cls` (not abstract)',
        );
      }
    }
  }
  return out.list;
}

/// CLS-07: viewmodel is `@riverpod class XViewmodel extends _$XViewmodel`
/// with `@override build()`, the `.g.dart` part and `riverpod_annotation`.
List<Violation> checkCls07(ProjectRoot root) {
  final out = _Out('CLS-07');
  for (final c in featureContexts(root)) {
    final path = c.viewmodelPath;
    if (!root.fileExists(path)) continue;
    final text = codeText(root, path);
    final n = '${c.entityPascal}Viewmodel';
    if (!RegExp(
      r'@riverpod\s+class\s+' + n + r'\s+extends\s+_\$' + n + r'\s*\{',
    ).hasMatch(text)) {
      out.add(path, null, 'expected `@riverpod class $n extends _\$$n`');
    }
    if (RegExp(r'@riverpod\s*\(').hasMatch(text)) {
      out.add(path, null, '@riverpod must have no arguments');
    }
    if (!RegExp(r'@override\s+[\w<>?, ]+\s+build\s*\(').hasMatch(text)) {
      out.add(path, null, 'missing `@override ... build()`');
    }
    if (!partDirectives(
      root,
      path,
    ).any((p) => p.uri == '${stem(path)}.g.dart')) {
      out.add(path, null, "missing part '${stem(path)}.g.dart'");
    }
    if (!root
        .directives(path)
        .any(
          (d) =>
              d.uri == 'package:riverpod_annotation/riverpod_annotation.dart',
        )) {
      out.add(path, null, 'missing import of package:riverpod_annotation');
    }
  }
  return out.list;
}

/// CLS-08: screen `extends ConsumerWidget` with `const XScreen({super.key});`,
/// item view `extends StatelessWidget` with
/// `const XItemView({super.key, required this.data});`.
List<Violation> checkCls08(ProjectRoot root) {
  final out = _Out('CLS-08');
  for (final c in _apiContexts(root)) {
    for (final path in c.screenPaths) {
      final text = codeText(root, path);
      final n = snakeToPascal(stem(path));
      if (!RegExp(
        r'class\s+' + n + r'\s+extends\s+ConsumerWidget\b',
      ).hasMatch(text)) {
        out.add(path, null, 'screen must be `class $n extends ConsumerWidget`');
      }
      if (!RegExp(
        r'const\s+' + n + r'\(\s*\{\s*super\.key\s*,?\s*\}\s*\)\s*;',
      ).hasMatch(text)) {
        out.add(path, null, 'screen needs `const $n({super.key});`');
      }
    }
    for (final path in c.itemViewPaths) {
      final text = codeText(root, path);
      final n = snakeToPascal(stem(path));
      if (!RegExp(
        r'class\s+' + n + r'\s+extends\s+StatelessWidget\b',
      ).hasMatch(text)) {
        out.add(
          path,
          null,
          'item view must be `class $n extends StatelessWidget`',
        );
      }
      if (!RegExp(
        r'const\s+' +
            n +
            r'\(\s*\{\s*super\.key\s*,\s*required\s+this\.data\s*,?\s*\}\s*\)\s*;',
      ).hasMatch(text)) {
        out.add(
          path,
          null,
          'item view needs `const $n({super.key, required this.data});`',
        );
      }
    }
  }
  return out.list;
}

// ---------------------------------------------------------------------------
// DI / GEN
// ---------------------------------------------------------------------------

/// DI-01: use case `@lazySingleton`; datasource remote and repository impl
/// `@LazySingleton(as: <abstract>)`; no `@singleton`/`@injectable` on feature
/// classes.
List<Violation> checkDi01(ProjectRoot root) {
  final out = _Out('DI-01');
  final forbidden = RegExp(
    r'^\s*@(singleton|injectable|Singleton|Injectable)\b',
    multiLine: true,
  );
  for (final c in featureContexts(root)) {
    for (final path in c.useCasePaths) {
      if (!RegExp(
        r'^\s*@lazySingleton\b',
        multiLine: true,
      ).hasMatch(codeText(root, path))) {
        out.add(path, null, 'use case needs @lazySingleton');
      }
    }
    for (final path in [if (c.isApi) c.remotePath, c.repositoryImplPath]) {
      if (!root.fileExists(path)) continue;
      final text = codeText(root, path);
      final m = RegExp(r'@LazySingleton\(\s*as:\s*(\w+)\s*\)').firstMatch(text);
      if (m == null) {
        out.add(path, null, 'needs @LazySingleton(as: <abstract>)');
      } else if (!RegExp(r'\bimplements\s+' + m.group(1)!).hasMatch(text)) {
        out.add(
          path,
          null,
          '@LazySingleton(as: ${m.group(1)}) but the class does not implement it',
        );
      }
    }
    for (final path in c.featureFiles) {
      final text = codeText(root, path);
      for (final m in forbidden.allMatches(text)) {
        out.add(
          path,
          lineOf(text, m.start),
          '${m.group(0)!.trim()} is not allowed on feature classes',
        );
      }
    }
  }
  return out.list;
}

/// GEN-02: `part` matches the annotation (`@freezed` -> `.freezed.dart`,
/// `@freezed` with `fromJson` -> also `.g.dart`, `@riverpod` -> `.g.dart`);
/// a `.freezed.dart` part needs `@freezed`.
List<Violation> checkGen02(ProjectRoot root) {
  final out = _Out('GEN-02');
  final freezed = RegExp(r'^\s*@[fF]reezed\b', multiLine: true);
  final riverpod = RegExp(r'^\s*@[rR]iverpod\b', multiLine: true);
  final fromJson = RegExp(r'factory\s+\w+\s*\.\s*fromJson\s*\(');
  for (final path in root.libFiles()) {
    final text = codeText(root, path);
    final parts = partDirectives(root, path).map((p) => p.uri).toSet();
    final s = stem(path);
    final hasFreezed = freezed.hasMatch(text);
    if (hasFreezed && !parts.contains('$s.freezed.dart')) {
      out.add(path, null, "@freezed needs part '$s.freezed.dart'");
    }
    if (hasFreezed && fromJson.hasMatch(text) && !parts.contains('$s.g.dart')) {
      out.add(path, null, "@freezed with fromJson needs part '$s.g.dart'");
    }
    if (riverpod.hasMatch(text) && !parts.contains('$s.g.dart')) {
      out.add(path, null, "@riverpod needs part '$s.g.dart'");
    }
    if (!hasFreezed && parts.contains('$s.freezed.dart')) {
      out.add(path, null, "part '$s.freezed.dart' without @freezed");
    }
  }
  return out.list;
}
