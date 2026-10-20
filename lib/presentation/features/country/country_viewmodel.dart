import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_state.dart';
import 'package:flutter_clean_riverpod/presentation/providers/di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'country_viewmodel.g.dart';

@riverpod
class CountryViewmodel extends _$CountryViewmodel {
  @override
  FutureOr<CountryState> build() async {
    final useCase = ref.watch(countryUseCaseProvider);
    final result = await useCase.fetchAllCountries();
    switch (result) {
      case Success(:final value):
        return CountryState.data(countries: value);
      case Failure(:final error):
        return CountryState.error(error);
    }
  }
}
