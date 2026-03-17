import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/domain/core/app_theme_mode.dart';
import 'package:flutter_clean_riverpod/domain/use_cases/theme/theme_use_case.dart';
import 'package:flutter_clean_riverpod/presentation/providers/di_providers.dart';
import 'package:flutter_clean_riverpod/presentation/theme/theme_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'theme_viewmodel_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThemeUseCase>()])
void main() {
  late MockThemeUseCase themeUseCase;

  setUp(() {
    themeUseCase = MockThemeUseCase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        themeUseCaseProvider.overrideWithValue(themeUseCase),
      ],
    );
  }

  group('build (initial fetch)', () {
    test('returns ThemeMode.light when use case returns AppThemeMode.light', () async {
      when(themeUseCase.fetch()).thenAnswer((_) async => AppThemeMode.light);

      final container = createContainer();
      addTearDown(container.dispose);

      final result = await container.read(themeViewmodelProvider.future);

      expect(result, equals(ThemeMode.light));
      verify(themeUseCase.fetch()).called(1);
    });

    test('returns ThemeMode.dark when use case returns AppThemeMode.dark', () async {
      when(themeUseCase.fetch()).thenAnswer((_) async => AppThemeMode.dark);

      final container = createContainer();
      addTearDown(container.dispose);

      final result = await container.read(themeViewmodelProvider.future);

      expect(result, equals(ThemeMode.dark));
    });

    test('returns ThemeMode.system when use case returns AppThemeMode.system', () async {
      when(themeUseCase.fetch()).thenAnswer((_) async => AppThemeMode.system);

      final container = createContainer();
      addTearDown(container.dispose);

      final result = await container.read(themeViewmodelProvider.future);

      expect(result, equals(ThemeMode.system));
    });
  });

  group('setTheme', () {
    test('saves light theme and updates state', () async {
      when(themeUseCase.fetch()).thenAnswer((_) async => AppThemeMode.system);
      when(themeUseCase.save(AppThemeMode.light)).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      // Wait for initial build
      await container.read(themeViewmodelProvider.future);

      // Set new theme
      await container.read(themeViewmodelProvider.notifier).setTheme(ThemeMode.light);

      verify(themeUseCase.save(AppThemeMode.light)).called(1);
      final newState = container.read(themeViewmodelProvider);
      expect(newState.value, equals(ThemeMode.light));
    });

    test('saves dark theme and updates state', () async {
      when(themeUseCase.fetch()).thenAnswer((_) async => AppThemeMode.light);
      when(themeUseCase.save(AppThemeMode.dark)).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(themeViewmodelProvider.future);
      await container.read(themeViewmodelProvider.notifier).setTheme(ThemeMode.dark);

      verify(themeUseCase.save(AppThemeMode.dark)).called(1);
      expect(container.read(themeViewmodelProvider).value, equals(ThemeMode.dark));
    });
  });
}
