import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/theme/theme_repository.dart';

part 'theme_viewmodel.g.dart';

@riverpod
class ThemeViewmodel extends _$ThemeViewmodel {
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
