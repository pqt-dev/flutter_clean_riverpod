import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'generated/codegen_loader.g.dart';
import 'infrastructure/constants/app_constants.dart';
import 'infrastructure/constants/locale_constants.dart';
import 'infrastructure/di/injection.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/theme_mode_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(
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
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeViewmodelProvider);
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.value ?? ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: AppRouter.router,
    );
  }
}
