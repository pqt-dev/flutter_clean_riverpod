import 'package:flutter_clean_riverpod/domain/core/app_theme_mode.dart';

abstract class ThemeRepository {
  Future<AppThemeMode> fetch();

  Future<void> save(AppThemeMode theme);
}
