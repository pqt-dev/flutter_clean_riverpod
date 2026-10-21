import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/generated/codegen_loader.g.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/app_constants.dart';
import 'package:flutter_clean_riverpod/infrastructure/constants/locale_constants.dart';
import 'package:flutter_clean_riverpod/presentation/counter_screen.dart';
import 'package:flutter_clean_riverpod/presentation/router/app_router.dart';
import 'package:flutter_clean_riverpod/presentation/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('AppRouter shows CounterScreen at the initial location', (
    tester,
  ) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [LocaleConstants.enUS],
        path: AppConstants.assetTranslationPath,
        fallbackLocale: LocaleConstants.enUS,
        assetLoader: const CodegenLoader(),
        startLocale: LocaleConstants.enUS,
        child: Builder(
          builder: (context) => MaterialApp.router(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CounterScreen), findsOneWidget);
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
  });
}
