import 'package:flutter_test/flutter_test.dart';

import 'checks/layer_checks.dart';
import 'support/fixture.dart';
import 'support/project.dart';

final _real = ProjectRoot();

void _expectNoViolations(Iterable<Violation> violations) {
  expect(
    violations,
    isEmpty,
    reason: violations.map((v) => '  $v').join('\n'),
  );
}

/// Negative test: [bad] must yield violations all carrying [ruleId];
/// [good] must yield none.
void _negative(
  String ruleId,
  List<Violation> Function(ProjectRoot) check, {
  required Map<String, String> bad,
  required Map<String, String> good,
}) {
  test('$ruleId catches violations in a fixture project', () {
    final p = FixtureProject(bad);
    addTearDown(p.dispose);
    final violations = check(p.root);
    expect(violations, isNotEmpty);
    expect(violations.map((v) => v.ruleId).toSet(), {ruleId});
  });

  test('$ruleId reports nothing for a valid fixture project', () {
    final p = FixtureProject(good);
    addTearDown(p.dispose);
    expect(check(p.root), isEmpty);
  });
}

void main() {
  test('sanity: every layer has scanned files', () {
    for (final layer in ['domain', 'data', 'infrastructure', 'presentation']) {
      expect(
        _real.libFiles(layer),
        isNotEmpty,
        reason:
            'No files found in lib/$layer (run tests from the project root)',
      );
    }
  });

  group('ARC-01 domain imports', () {
    test('real project has no violations', () {
      _expectNoViolations(checkArc01(_real));
    });
    _negative(
      'ARC-01',
      checkArc01,
      bad: {
        'lib/domain/a.dart': "import 'package:flutter/material.dart';\n",
        'lib/domain/b.dart': "import 'package:sample_app/data/x.dart';\n",
        'lib/domain/c.dart': "import '../presentation/y.dart';\n",
      },
      good: {
        'lib/domain/a.dart': "import 'package:sample_app/domain/b.dart';\n",
        'lib/domain/b.dart': "import 'dart:io';\n",
      },
    );
  });

  group('ARC-02 presentation must not import data', () {
    test('real project has no violations', () {
      _expectNoViolations(checkArc02(_real));
    });
    _negative(
      'ARC-02',
      checkArc02,
      bad: {'lib/presentation/a.dart': "import '../data/x.dart';\n"},
      good: {
        'lib/presentation/a.dart':
            "import 'package:sample_app/domain/x.dart';\n",
      },
    );
  });

  group('ARC-03 data must not import presentation', () {
    test('real project has no violations', () {
      _expectNoViolations(checkArc03(_real));
    });
    _negative(
      'ARC-03',
      checkArc03,
      bad: {
        'lib/data/a.dart': "import 'package:sample_app/presentation/x.dart';\n",
      },
      good: {'lib/data/a.dart': "import 'package:sample_app/domain/x.dart';\n"},
    );
  });

  group('ARC-04 getIt only in di_providers', () {
    test('real project has no violations', () {
      _expectNoViolations(checkArc04(_real));
    });
    _negative(
      'ARC-04',
      checkArc04,
      bad: {'lib/presentation/a.dart': 'final x = getIt<Foo>();\n'},
      good: {
        'lib/presentation/providers/di_providers.dart':
            'final x = getIt<Foo>();\n',
        'lib/presentation/a.dart': '// getIt in a comment\n',
      },
    );
  });

  group('ARC-05 viewmodel must not import repositories', () {
    test('real project has no violations', () {
      _expectNoViolations(checkArc05(_real));
    });
    _negative(
      'ARC-05',
      checkArc05,
      bad: {
        'lib/presentation/x_viewmodel.dart':
            "import 'package:sample_app/domain/repositories/x/x_repository.dart';\n",
      },
      good: {
        'lib/presentation/x_viewmodel.dart':
            "import 'package:sample_app/domain/use_cases/x/x_use_case.dart';\n",
        'lib/presentation/other.dart':
            "import 'package:sample_app/domain/repositories/x/x_repository.dart';\n",
      },
    );
  });

  group('ARC-08 no print in lib', () {
    test('real project has no violations', () {
      _expectNoViolations(checkArc08(_real));
    });
    _negative(
      'ARC-08',
      checkArc08,
      bad: {'lib/data/a.dart': "void f() { print('x'); }\n"},
      good: {
        'lib/infrastructure/services/logger_service.dart':
            "void f() { print('x'); }\n",
        'lib/data/a.dart': "// print('x')\nvoid g() { sprint(1); }\n",
      },
    );
  });
}
