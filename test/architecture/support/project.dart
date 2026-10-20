import 'dart:io';

/// A rule violation found by an architecture check.
class Violation {
  const Violation(this.ruleId, this.path, this.line, this.message);

  final String ruleId;

  /// Path relative to the project root, using `/`.
  final String path;
  final int? line;
  final String message;

  @override
  String toString() =>
      '[$ruleId] $path${line == null ? '' : ':$line'} $message';
}

/// One source line of a file.
class SourceLine {
  SourceLine(this.path, this.number, this.text);

  final String path;
  final int number;
  final String text;

  bool get isComment => text.trimLeft().startsWith('//');
}

/// An `import`/`export` directive.
class Directive extends SourceLine {
  Directive(super.path, super.number, super.text, this.uri, this.target);

  final String uri;

  /// Path of the imported file relative to the project root (e.g. `lib/data/x.dart`),
  /// or null for non-project imports (dart:, other packages).
  final String? target;

  bool targetIn(String layer) => target?.startsWith('lib/$layer/') ?? false;
}

enum FeatureKind { api, local }

class Feature {
  const Feature(this.name, this.kind);

  final String name;
  final FeatureKind kind;

  @override
  String toString() => 'Feature($name, ${kind.name})';
}

final _directiveRegex = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');
final _pubspecNameRegex = RegExp(r'^name:\s*(\S+)', multiLine: true);

const generatedSuffixes = [
  '.g.dart',
  '.freezed.dart',
  '.config.dart',
  '.gen.dart',
  '.mocks.dart',
];

/// Root directory of a project (the real one, or a fixture in a temp dir).
/// All paths taken/returned are relative to the root and use `/`.
class ProjectRoot {
  ProjectRoot([this.path = '.', String? appPackage])
    : _appPackageOverride = appPackage;

  final String path;
  final String? _appPackageOverride;

  /// App package name: the constructor argument if given, else `name:` in the
  /// root's `pubspec.yaml`. Throws if neither is available.
  String get appPackage {
    if (_appPackageOverride != null) return _appPackageOverride;
    final pubspec = File('$path/pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw StateError('No pubspec.yaml in $path and no appPackage given');
    }
    final match = _pubspecNameRegex.firstMatch(pubspec.readAsStringSync());
    if (match == null) throw StateError('No `name:` in $path/pubspec.yaml');
    return match.group(1)!;
  }

  String _abs(String rel) => '$path/$rel';

  bool fileExists(String rel) => File(_abs(rel)).existsSync();

  bool dirExists(String rel) => Directory(_abs(rel)).existsSync();

  /// Sorted names of the direct subdirectories of [rel] (empty if missing).
  List<String> subdirs(String rel) {
    final dir = Directory(_abs(rel));
    if (!dir.existsSync()) return [];
    return dir
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.replaceAll(r'\', '/').split('/').last)
        .toList()
      ..sort();
  }

  /// `.dart` files under [rel] (recursive), as root-relative paths, sorted.
  List<String> dartFilesIn(String rel, {bool includeGenerated = false}) {
    final dir = Directory(_abs(rel));
    if (!dir.existsSync()) return [];
    final prefix = '${Directory(path).absolute.path.replaceAll(r'\', '/')}/';
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.absolute.path.replaceAll(r'\', '/'))
        .where((p) => p.startsWith(prefix))
        .map((p) => p.substring(prefix.length))
        .where((p) => p.endsWith('.dart'))
        .where((p) => includeGenerated || !generatedSuffixes.any(p.endsWith))
        .toList()
      ..sort();
  }

  /// Dart files under `lib/<layer>` (all of `lib/` when [layer] is empty).
  List<String> libFiles([String layer = '', bool includeGenerated = false]) =>
      dartFilesIn(
        layer.isEmpty ? 'lib' : 'lib/$layer',
        includeGenerated: includeGenerated,
      );

  /// Dart files under `test/`.
  List<String> testFiles({bool includeGenerated = false}) =>
      dartFilesIn('test', includeGenerated: includeGenerated);

  List<SourceLine> lines(String rel) {
    final lines = File(_abs(rel)).readAsLinesSync();
    return [
      for (var i = 0; i < lines.length; i++) SourceLine(rel, i + 1, lines[i]),
    ];
  }

  /// `import`/`export` directives of [rel].
  List<Directive> directives(String rel) {
    final result = <Directive>[];
    for (final line in lines(rel)) {
      final match = _directiveRegex.firstMatch(line.text);
      if (match == null) continue;
      final uri = match.group(1)!;
      result.add(
        Directive(rel, line.number, line.text, uri, resolveUri(rel, uri)),
      );
    }
    return result;
  }

  /// Resolves [uri] imported from [fromPath] to a root-relative path
  /// (`lib/...`), or null for dart:/other packages.
  String? resolveUri(String fromPath, String uri) {
    final prefix = 'package:$appPackage/';
    if (uri.startsWith(prefix)) return 'lib/${uri.substring(prefix.length)}';
    if (uri.contains(':')) return null;
    return Uri.parse(fromPath).resolve(uri).path;
  }

  /// Non-comment lines of [files] matching [regex].
  List<SourceLine> linesMatching(
    Iterable<String> files,
    RegExp regex, {
    bool Function(String path)? skip,
  }) {
    return [
      for (final file in files)
        if (skip == null || !skip(file))
          for (final line in lines(file))
            if (!line.isComment && regex.hasMatch(line.text)) line,
    ];
  }
}

/// The ONLY definition of "feature": a feature exists iff the directory
/// `lib/domain/use_cases/<name>/` exists. It is [FeatureKind.api] when
/// `lib/data/datasource/<name>/` also exists, otherwise [FeatureKind.local].
/// (`core` is not a feature and never appears under use_cases.)
List<Feature> discoverFeatures(ProjectRoot root) => [
  for (final name in root.subdirs('lib/domain/use_cases'))
    Feature(
      name,
      root.dirExists('lib/data/datasource/$name')
          ? FeatureKind.api
          : FeatureKind.local,
    ),
];

/// Entity name of [feature]: for API features the part before `_use_case.dart`
/// of the (first, sorted) use case file in `lib/domain/use_cases/<name>/`
/// (null if none); for local features the feature name itself.
String? entityName(ProjectRoot root, Feature feature) {
  if (feature.kind == FeatureKind.local) return feature.name;
  const suffix = '_use_case.dart';
  for (final file in root.dartFilesIn('lib/domain/use_cases/${feature.name}')) {
    final base = file.split('/').last;
    if (base.endsWith(suffix)) {
      return base.substring(0, base.length - suffix.length);
    }
  }
  return null;
}

/// `country_name` -> `CountryName`.
String snakeToPascal(String s) => [
  for (final part in s.split('_'))
    if (part.isNotEmpty) part[0].toUpperCase() + part.substring(1),
].join();

/// `country_name` -> `countryName`.
String snakeToCamel(String s) {
  final pascal = snakeToPascal(s);
  return pascal.isEmpty
      ? pascal
      : pascal[0].toLowerCase() + pascal.substring(1);
}
