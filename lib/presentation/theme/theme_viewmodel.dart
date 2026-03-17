import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/domain/core/app_theme_mode.dart';
import 'package:flutter_clean_riverpod/presentation/providers/di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_viewmodel.g.dart';

@riverpod
class ThemeViewmodel extends _$ThemeViewmodel {
  @override
  FutureOr<ThemeMode> build() async {
    final useCase = ref.watch(themeUseCaseProvider);
    final appThemeMode = await useCase.fetch();
    return _toThemeMode(appThemeMode);
  }

  Future<void> setTheme(ThemeMode theme) async {
    final useCase = ref.watch(themeUseCaseProvider);
    final appThemeMode = _toAppThemeMode(theme);
    await useCase.save(appThemeMode);
    state = AsyncData(theme);
  }

  ThemeMode _toThemeMode(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }

  AppThemeMode _toAppThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.dark => AppThemeMode.dark,
      ThemeMode.system => AppThemeMode.system,
    };
  }
}

