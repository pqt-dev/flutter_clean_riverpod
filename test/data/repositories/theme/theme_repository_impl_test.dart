import 'package:flutter_clean_riverpod/data/repositories/theme/theme_repository_impl.dart';
import 'package:flutter_clean_riverpod/domain/core/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeRepositoryImpl repository;

  group('fetch', () {
    test('returns AppThemeMode.light when stored value is "light"', () async {
      SharedPreferences.setMockInitialValues({'theme_mode_key': 'light'});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      final result = await repository.fetch();

      expect(result, equals(AppThemeMode.light));
    });

    test('returns AppThemeMode.dark when stored value is "dark"', () async {
      SharedPreferences.setMockInitialValues({'theme_mode_key': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      final result = await repository.fetch();

      expect(result, equals(AppThemeMode.dark));
    });

    test('returns AppThemeMode.system when stored value is "system"', () async {
      SharedPreferences.setMockInitialValues({'theme_mode_key': 'system'});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      final result = await repository.fetch();

      expect(result, equals(AppThemeMode.system));
    });

    test('returns AppThemeMode.system when no value stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      final result = await repository.fetch();

      expect(result, equals(AppThemeMode.system));
    });

    test('returns AppThemeMode.system for unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode_key': 'unknown_value'});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      final result = await repository.fetch();

      expect(result, equals(AppThemeMode.system));
    });
  });

  group('save', () {
    test('saves light theme as "light" string', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      await repository.save(AppThemeMode.light);

      expect(prefs.getString('theme_mode_key'), equals('light'));
    });

    test('saves dark theme as "dark" string', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      await repository.save(AppThemeMode.dark);

      expect(prefs.getString('theme_mode_key'), equals('dark'));
    });

    test('saves system theme as "system" string', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      await repository.save(AppThemeMode.system);

      expect(prefs.getString('theme_mode_key'), equals('system'));
    });

    test('save then fetch returns same theme', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      await repository.save(AppThemeMode.dark);
      final result = await repository.fetch();

      expect(result, equals(AppThemeMode.dark));
    });

    test('overwriting previously saved theme', () async {
      SharedPreferences.setMockInitialValues({'theme_mode_key': 'light'});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);

      await repository.save(AppThemeMode.dark);
      final result = await repository.fetch();

      expect(result, equals(AppThemeMode.dark));
    });
  });
}
