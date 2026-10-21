import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/features/widgets/app_bar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  final backIcon = find.byWidgetPredicate(
    (widget) =>
        widget is Icon &&
        (widget.icon == Icons.arrow_back_outlined ||
            widget.icon == Icons.arrow_back_ios_outlined),
  );

  testWidgets('back pops the route under plain MaterialApp without GoRouter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: const AppBarView(title: 'Second'),
                    body: const Text('second body'),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('second body'), findsOneWidget);

    await tester.tap(backIcon);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('second body'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('back pops via go_router when a GoRouter exists', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('first body')),
        ),
        GoRoute(
          path: '/second',
          builder: (_, _) => Scaffold(
            appBar: const AppBarView(title: 'Second'),
            body: const Text('second body'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.push('/second');
    await tester.pumpAndSettle();
    expect(find.text('second body'), findsOneWidget);

    await tester.tap(backIcon);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('second body'), findsNothing);
    expect(find.text('first body'), findsOneWidget);
  });

  testWidgets('back invokes onBack and does not pop', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: AppBarView(title: 'Second', onBack: () => calls++),
                    body: const Text('second body'),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(backIcon);
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text('second body'), findsOneWidget);
  });
}
