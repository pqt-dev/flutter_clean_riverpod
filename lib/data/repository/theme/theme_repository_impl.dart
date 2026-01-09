import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/data/repository/theme/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/common/constants.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferences preferences;

  ThemeRepositoryImpl(this.preferences);

  @override
  Future<ThemeMode> fetch() async {
    final themeName = preferences.getString(Constants.themeModeKey);
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
    await preferences.setString(Constants.themeModeKey, theme.name);
  }
}
