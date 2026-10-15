import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _package = 'flutter_clean_riverpod';
const _generatedSuffixes = [
  '.g.dart',
  '.freezed.dart',
  '.config.dart',
  '.gen.dart',
  '.mocks.dart',
];
const _diProvidersPath = 'lib/presentation/providers/di_providers.dart';
const _loggerServicePath = 'lib/infrastructure/services/logger_service.dart';

final _directiveRegex = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');
final _getItRegex = RegExp(r'\bgetIt\b');
final _printRegex = RegExp(r'(?<![\w$])(?:print|debugPrint)\(');

class _Line {
  _Line(this.path, this.number, this.text);

  final String path;
  final int number;
  final String text;

  bool get isComment => text.trimLeft().startsWith('//');

  @override
  String toString() => '$path:$number: ${text.trim()}';
}

class _Directive extends _Line {
  _Directive(super.path, super.number, super.text, this.uri, this.target);

  final String uri;

  /// Path of the imported file relative to the project root (e.g. `lib/data/x.dart`),
  /// or null for non-project imports (dart:, other packages).
  final String? target;

  bool targetIn(String layer) => target?.startsWith('lib/$layer/') ?? false;
}

/// Non-generated `.dart` files under `lib/`, as project-root-relative paths.
List<String> _libFiles([String layer = '']) {
  final dir = Directory('lib/$layer');
  if (!dir.existsSync()) return [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.replaceAll(r'\', '/'))
      .where((p) => p.endsWith('.dart'))
      .where((p) => !_generatedSuffixes.any(p.endsWith))
      .toList()
    ..sort();
}

List<_Line> _lines(String path) {
  final lines = File(path).readAsLinesSync();
  return [for (var i = 0; i < lines.length; i++) _Line(path, i + 1, lines[i])];
}

String? _resolve(String path, String uri) {
  const prefix = 'package:$_package/';
  if (uri.startsWith(prefix)) return 'lib/${uri.substring(prefix.length)}';
  if (uri.contains(':')) return null;
  final base = Uri.parse(path);
  return base.resolve(uri).path;
}

List<_Directive> _directives(String path) {
  final result = <_Directive>[];
  for (final line in _lines(path)) {
    final match = _directiveRegex.firstMatch(line.text);
    if (match == null) continue;
    final uri = match.group(1)!;
    result.add(
      _Directive(path, line.number, line.text, uri, _resolve(path, uri)),
    );
  }
  return result;
}

List<_Line> _linesMatching(
  Iterable<String> files,
  RegExp regex, {
  bool Function(String path)? skip,
}) {
  return [
    for (final path in files)
      if (skip == null || !skip(path))
        for (final line in _lines(path))
          if (!line.isComment && regex.hasMatch(line.text)) line,
  ];
}

void _expectNoViolations(String rule, Iterable<_Line> violations) {
  expect(
    violations,
    isEmpty,
    reason: '$rule\n${violations.map((v) => '  $v').join('\n')}',
  );
}

void main() {
  test('sanity: every layer has scanned files', () {
    for (final layer in ['domain', 'data', 'infrastructure', 'presentation']) {
      expect(
        _libFiles(layer),
        isNotEmpty,
        reason:
            'No files found in lib/$layer (run tests from the project root)',
      );
    }
  });

  test('domain must not import flutter, dio, data or presentation', () {
    final violations = [
      for (final path in _libFiles('domain'))
        for (final d in _directives(path))
          if (d.uri.startsWith('package:flutter/') ||
              d.uri.startsWith('package:dio/') ||
              d.targetIn('data') ||
              d.targetIn('presentation'))
            d,
    ];
    _expectNoViolations('lib/domain/ has forbidden imports:', violations);
  });

  test('presentation must not import data', () {
    final violations = [
      for (final path in _libFiles('presentation'))
        for (final d in _directives(path))
          if (d.targetIn('data')) d,
    ];
    _expectNoViolations('lib/presentation/ must not import data/:', violations);
  });

  test('getIt is only used in presentation/providers/di_providers.dart', () {
    final violations = _linesMatching(
      _libFiles('presentation'),
      _getItRegex,
      skip: (p) => p == _diProvidersPath,
    );
    _expectNoViolations(
      'getIt is only allowed in $_diProvidersPath:',
      violations,
    );
  });

  test('viewmodels must not import domain repositories', () {
    final violations = [
      for (final path in _libFiles('presentation'))
        if (path.endsWith('_viewmodel.dart'))
          for (final d in _directives(path))
            if (d.targetIn('domain/repositories')) d,
    ];
    _expectNoViolations(
      'ViewModel must only use UseCase, not repositories:',
      violations,
    );
  });

  test('no print/debugPrint in lib (use LoggerService)', () {
    final violations = _linesMatching(
      _libFiles(),
      _printRegex,
      skip: (p) => p == _loggerServicePath,
    );
    _expectNoViolations('Use LoggerService instead of print:', violations);
  });
}
