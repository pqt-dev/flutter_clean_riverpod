import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../infrastructure/constants/storage_keys.dart';
import '../../../domain/repositories/theme/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferences preferences;

  ThemeRepositoryImpl(this.preferences);

  @override
  Future<ThemeMode> fetch() async {
    final themeName = preferences.getString(StorageKeys.themeModeKey);
    switch (themeName) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> save(ThemeMode theme) async {
    await preferences.setString(StorageKeys.themeModeKey, theme.name);
  }
}
