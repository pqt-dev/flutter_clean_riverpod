import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_clean_riverpod/domain/use_cases/country/country_use_case.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_state.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'country_viewmodel_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CountryUseCase>()])
void main() {
  late final MockCountryUseCase countryUseCase;
  setUp(() {
    countryUseCase = MockCountryUseCase();
    if (GetIt.instance.isRegistered<CountryUseCase>()) {
      GetIt.instance.unregister<CountryUseCase>();
    }
    GetIt.instance.registerSingleton<CountryUseCase>(countryUseCase);
  });
  test(
    'Test whether the CountryViewmodel instance is initialized and `initialize()` function is successful',
    () async {
      final container = ProviderContainer();
      final mockResponseSuccess = Success([Country(), Country()]);
      provideDummy<Result<List<Country>>>(mockResponseSuccess);
      when(countryUseCase.fetchAllCountries()).thenAnswer((_) async => mockResponseSuccess);
      final future = container.read(countryViewmodelProvider.future);
      addTearDown(container.dispose);
      await expectLater(
        future,
        completion(
          isA<CountryState>()
              .having(
                (state) => state.countries.length,
                'List of country has 2 items',
                equals(2),
              )
              .having(
                (state) => state.countries,
                'Is a list of CountryResponse',
                isA<List<Country>>(),
              ),
        ),
      );
    },
  );
}
