import 'package:flutter_clean_riverpod/domain/core/app_theme_mode.dart';
import 'package:flutter_clean_riverpod/domain/repositories/theme/theme_repository.dart';
import 'package:flutter_clean_riverpod/domain/use_cases/theme/theme_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'theme_use_case_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThemeRepository>()])
void main() {
  late MockThemeRepository repository;
  late ThemeUseCase useCase;

  setUp(() {
    repository = MockThemeRepository();
    useCase = ThemeUseCase(repository);
  });

  group('fetch', () {
    test('returns light theme from repository', () async {
      when(repository.fetch()).thenAnswer((_) async => AppThemeMode.light);

      final result = await useCase.fetch();

      expect(result, equals(AppThemeMode.light));
      verify(repository.fetch()).called(1);
    });

    test('returns dark theme from repository', () async {
      when(repository.fetch()).thenAnswer((_) async => AppThemeMode.dark);

      final result = await useCase.fetch();

      expect(result, equals(AppThemeMode.dark));
    });

    test('returns system theme from repository', () async {
      when(repository.fetch()).thenAnswer((_) async => AppThemeMode.system);

      final result = await useCase.fetch();

      expect(result, equals(AppThemeMode.system));
    });
  });

  group('save', () {
    test('saves light theme to repository', () async {
      when(repository.save(AppThemeMode.light)).thenAnswer((_) async {});

      await useCase.save(AppThemeMode.light);

      verify(repository.save(AppThemeMode.light)).called(1);
    });

    test('saves dark theme to repository', () async {
      when(repository.save(AppThemeMode.dark)).thenAnswer((_) async {});

      await useCase.save(AppThemeMode.dark);

      verify(repository.save(AppThemeMode.dark)).called(1);
    });
  });
}
