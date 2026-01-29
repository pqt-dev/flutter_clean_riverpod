import 'package:flutter_clean_riverpod/domain/use_cases/country/country_use_case.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/core/result.dart';
import '../../../infrastructure/di/injection.dart';

part 'country_viewmodel.g.dart';

@riverpod
class CountryViewmodel extends _$CountryViewmodel {
  final useCase = getIt.get<CountryUseCase>();

  @override
  FutureOr<CountryState> build() async {
    final result = await useCase.fetchAllCountries();
    switch (result) {
      case Success(:final value):
        return CountryState(
          countries: value,
        );
      case Failure(:final error):
        throw error;
    }
  }
}
