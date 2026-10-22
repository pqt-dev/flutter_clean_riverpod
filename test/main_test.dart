import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/generated/codegen_loader.g.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/app_constants.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/locale_constants.dart';
import 'package:flutter_clean_riverpod/infrastructure/di/injection.dart';
import 'package:flutter_clean_riverpod/main.dart';
import 'package:flutter_clean_riverpod/presentation/counter_screen.dart';
import 'package:flutter_clean_riverpod/presentation/theme/app_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await configureDependencies();
  });

  testWidgets(
    'CounterScreen renders correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: const [
              LocaleConstants.enUS,
              LocaleConstants.viVN,
              LocaleConstants.jaJP,
            ],
            path: AppConstants.assetTranslationPath,
            fallbackLocale: LocaleConstants.enUS,
            assetLoader: const CodegenLoader(),
            startLocale: LocaleConstants.enUS,
            child: const MyApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CounterScreen), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.extension<AppThemeExtension>(), isNotNull);
      expect(app.darkTheme?.extension<AppThemeExtension>(), isNotNull);
    },
  );
}
