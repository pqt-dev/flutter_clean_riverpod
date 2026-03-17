import 'package:flutter_clean_riverpod/domain/core/app_theme_mode.dart';
import 'package:flutter_clean_riverpod/domain/repositories/theme/theme_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ThemeUseCase {
  final ThemeRepository repository;

  ThemeUseCase(this.repository);

  Future<AppThemeMode> fetch() async {
    return repository.fetch();
  }

  Future<void> save(AppThemeMode theme) async {
    return repository.save(theme);
  }
}
