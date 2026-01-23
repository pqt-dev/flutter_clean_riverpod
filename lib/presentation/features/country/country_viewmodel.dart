import 'package:flutter_clean_riverpod/infrastructure/di/injection.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasource/remote/api_result.dart';
import '../../../data/repositories/country/country_repository.dart';

part 'country_viewmodel.g.dart';

@riverpod
class CountryViewmodel extends _$CountryViewmodel {
  final repository = getIt.get<CountryRepository>();

  @override
  FutureOr<CountryState> build() async {
    final result = await repository.fetchAllCountries();
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
