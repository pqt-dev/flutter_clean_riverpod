import 'package:flutter_clean_riverpod/domain/use_cases/country/country_use_case.dart';
import 'package:flutter_clean_riverpod/domain/use_cases/theme/theme_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/di/injection.dart';

/// Riverpod providers that bridge GetIt (infrastructure DI) → Riverpod (presentation DI).
/// This allows ViewModels to use [ref.watch] instead of calling [getIt] directly,
/// preserving Riverpod's dependency graph for testability and overrides.

final countryUseCaseProvider = Provider<CountryUseCase>((ref) {
  return getIt<CountryUseCase>();
});

final themeUseCaseProvider = Provider<ThemeUseCase>((ref) {
  return getIt<ThemeUseCase>();
});
