import '../support/project.dart';

const diProvidersPath = 'lib/presentation/providers/di_providers.dart';
const loggerServicePath = 'lib/infrastructure/services/logger_service.dart';

final _getItRegex = RegExp(r'\bgetIt\b');
final _printRegex = RegExp(r'(?<![\w$])(?:print|debugPrint)\(');

/// ARC-01: lib/domain must not import flutter, dio, data or presentation.
List<Violation> checkArc01(ProjectRoot root) => [
  for (final path in root.libFiles('domain'))
    for (final d in root.directives(path))
      if (d.uri.startsWith('package:flutter/') ||
          d.uri.startsWith('package:dio/') ||
          d.targetIn('data') ||
          d.targetIn('presentation'))
        Violation(
          'ARC-01',
          path,
          d.number,
          'domain must not import flutter, dio, data or presentation: ${d.uri}',
        ),
];

/// ARC-02: lib/presentation must not import lib/data.
List<Violation> checkArc02(ProjectRoot root) => [
  for (final path in root.libFiles('presentation'))
    for (final d in root.directives(path))
      if (d.targetIn('data'))
        Violation(
          'ARC-02',
          path,
          d.number,
          'presentation must not import data: ${d.uri}',
        ),
];

/// ARC-03: lib/data must not import lib/presentation.
List<Violation> checkArc03(ProjectRoot root) => [
  for (final path in root.libFiles('data'))
    for (final d in root.directives(path))
      if (d.targetIn('presentation'))
        Violation(
          'ARC-03',
          path,
          d.number,
          'data must not import presentation: ${d.uri}',
        ),
];

/// ARC-04: in lib/presentation only providers/di_providers.dart may use getIt.
List<Violation> checkArc04(ProjectRoot root) => [
  for (final l in root.linesMatching(
    root.libFiles('presentation'),
    _getItRegex,
    skip: (p) => p == diProvidersPath,
  ))
    Violation(
      'ARC-04',
      l.path,
      l.number,
      'getIt is only allowed in $diProvidersPath: ${l.text.trim()}',
    ),
];

/// ARC-05: *_viewmodel.dart must not import lib/domain/repositories.
List<Violation> checkArc05(ProjectRoot root) => [
  for (final path in root.libFiles('presentation'))
    if (path.endsWith('_viewmodel.dart'))
      for (final d in root.directives(path))
        if (d.targetIn('domain/repositories'))
          Violation(
            'ARC-05',
            path,
            d.number,
            'viewmodel must only use UseCase, not repositories: ${d.uri}',
          ),
];

/// ARC-08: no print/debugPrint in lib (use LoggerService).
List<Violation> checkArc08(ProjectRoot root) => [
  for (final l in root.linesMatching(
    root.libFiles(),
    _printRegex,
    skip: (p) => p == loggerServicePath,
  ))
    Violation(
      'ARC-08',
      l.path,
      l.number,
      'use LoggerService instead of print: ${l.text.trim()}',
    ),
];
