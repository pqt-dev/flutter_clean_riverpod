import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/data/repository/theme/theme_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_viewmodel.g.dart';

@riverpod
class ThemeModeViewmodel extends _$ThemeModeViewmodel {
  final repository = GetIt.instance.get<ThemeRepository>();

  @override
  FutureOr<ThemeMode> build() async {
    return repository.fetch();
  }

  Future<void> setTheme(ThemeMode theme) async {
    await repository.save(theme);
    state = AsyncData(theme);
  }
}
