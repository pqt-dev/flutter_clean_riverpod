import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/generated/codegen_loader.g.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/app_constants.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/locale_constants.dart';
import 'package:flutter_clean_riverpod/presentation/counter_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('CounterScreen increments the counter on tap', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [LocaleConstants.enUS],
        path: AppConstants.assetTranslationPath,
        fallbackLocale: LocaleConstants.enUS,
        assetLoader: const CodegenLoader(),
        startLocale: LocaleConstants.enUS,
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const CounterScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flutter Demo Home Page'), findsOneWidget);
    expect(
      find.text('You have pushed the button this many times:'),
      findsOneWidget,
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
