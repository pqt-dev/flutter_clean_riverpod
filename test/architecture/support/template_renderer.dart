import 'dart:io';

/// Directory holding the feature templates, relative to the project root
/// (the working directory of `flutter test`).
const templatesDir = '.claude/templates';

final _markerLine = RegExp(r'^\s*//\s*tmpl:custom-(?:begin|end)\s*$');
final _leftoverToken = RegExp(r'\{\{[^}]*\}\}');

/// True when the template set [set] (`api-feature` / `local-feature`) exists
/// in the current project.
bool templateSetExists(String set) =>
    Directory('$templatesDir/$set').existsSync();

/// Renders every `*.tmpl` of `.claude/templates/<set>/` into
/// `path -> content`.
///
/// - Destination path = path relative to the set dir without `.tmpl`.
/// - [tokens] (`entity` -> `product`, replaced as `{{entity}}`) are applied to
///   both the path and the content.
/// - Files whose path contains `{{nested}}` or `{{Nested}}` are rendered once
///   per entry of [nested] (maps with `nested` / `Nested`); all others once.
/// - Lines holding only a `tmpl:custom-begin/end` marker are removed.
/// - [literals] are then applied (in map order) to the whole content, custom
///   regions included, to simulate a developer rewriting the sample code of
///   the custom regions for the new feature.
///
/// Throws [StateError] if a `{{token}}` is left over.
Map<String, String> renderTemplateSet(
  String set, {
  required Map<String, String> tokens,
  Map<String, String> literals = const {},
  List<Map<String, String>> nested = const [],
}) {
  final base = Directory('$templatesDir/$set');
  final basePath = '${base.absolute.path.replaceAll(r'\', '/')}/';
  final templates =
      base
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.tmpl'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final result = <String, String>{};
  for (final file in templates) {
    final rel = file.absolute.path
        .replaceAll(r'\', '/')
        .substring(basePath.length);
    final rawPath = rel.substring(0, rel.length - '.tmpl'.length);
    final content = file.readAsStringSync();
    final isNested =
        rawPath.contains('{{nested}}') || rawPath.contains('{{Nested}}');
    final variants = isNested ? nested : const [<String, String>{}];
    for (final extra in variants) {
      final all = {...tokens, ...extra};
      final path = _replaceTokens(rawPath, all);
      var text = _replaceTokens(
        content,
        all,
      ).split('\n').where((l) => !_markerLine.hasMatch(l)).join('\n');
      literals.forEach((from, to) => text = text.replaceAll(from, to));
      final left = _leftoverToken.firstMatch('$path\n$text');
      if (left != null) {
        throw StateError('Unreplaced token ${left.group(0)} in $set/$rel');
      }
      result[path] = text;
    }
  }
  return result;
}

String _replaceTokens(String s, Map<String, String> tokens) {
  var out = s;
  tokens.forEach((k, v) => out = out.replaceAll('{{$k}}', v));
  return out;
}
