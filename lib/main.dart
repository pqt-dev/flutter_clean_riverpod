import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/theme/app_theme.dart';
import 'package:flutter_clean_riverpod/service/app_initializer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'generated/codegen_loader.g.dart';
import 'presentation/common/app_constants.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/theme_controller.dart';

void main() async {
  await AppInitializer.getInstance.ensureInitialized();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [
          AppConstants.enUS,
          AppConstants.viVN,
          AppConstants.jaJP,
        ],
        path: AppConstants.assetTranslationPath,
        fallbackLocale: AppConstants.enUS,
        assetLoader: const CodegenLoader(),
        startLocale: AppConstants.enUS,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
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
