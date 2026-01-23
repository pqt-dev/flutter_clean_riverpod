import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_clean_riverpod/generated/codegen_loader.g.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/app_constants.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/locale_constants.dart';
import 'package:flutter_clean_riverpod/infrastructure/di/injection.dart';
import 'package:flutter_clean_riverpod/main.dart';
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
    'MainHomeScreen renders correctly',
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
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    },
  );
}
