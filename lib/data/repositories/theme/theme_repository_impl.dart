
import 'package:flutter_clean_riverpod/domain/core/app_theme_mode.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../infrastructure/constants/storage_keys.dart';
import '../../../domain/repositories/theme/theme_repository.dart';

@LazySingleton(as: ThemeRepository)
class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferences preferences;

  ThemeRepositoryImpl(this.preferences);

  @override
  Future<AppThemeMode> fetch() async {
    final themeName = preferences.getString(StorageKeys.themeModeKey);
    switch (themeName) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  @override
  Future<void> save(AppThemeMode theme) async {
    await preferences.setString(StorageKeys.themeModeKey, theme.name);
  }
}
