import 'dart:io';

import 'project.dart';

/// A throwaway fake project in the system temp dir, for negative tests.
/// Use: `final p = FixtureProject({...}); addTearDown(p.dispose);`
class FixtureProject {
  FixtureProject(Map<String, String> files) {
    _dir = Directory.systemTemp.createTempSync('arch_fixture_');
    _write('pubspec.yaml', 'name: sample_app\n');
    files.forEach(_write);
    root = ProjectRoot(_dir.path);
  }

  late final Directory _dir;
  late final ProjectRoot root;

  void _write(String rel, String content) {
    final file = File('${_dir.path}/$rel');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  void dispose() {
    if (_dir.existsSync()) _dir.deleteSync(recursive: true);
  }
}
