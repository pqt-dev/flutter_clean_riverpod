import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_clean_riverpod/domain/use_cases/country/country_use_case.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_state.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_viewmodel.dart';
import 'package:flutter_clean_riverpod/presentation/providers/di_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'country_viewmodel_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CountryUseCase>()])
void main() {
  late MockCountryUseCase countryUseCase;

  setUp(() {
    countryUseCase = MockCountryUseCase();
  });

  test(
    'CountryViewmodel fetches countries successfully',
    () async {
      final mockResponseSuccess = Success([Country(), Country()]);
      provideDummy<Result<List<Country>>>(mockResponseSuccess);
      when(countryUseCase.fetchAllCountries())
          .thenAnswer((_) async => mockResponseSuccess);

      // Use Riverpod overrides instead of GetIt hacking
      final container = ProviderContainer(
        overrides: [
          countryUseCaseProvider.overrideWithValue(countryUseCase),
        ],
      );
      addTearDown(container.dispose);

      final future = container.read(countryViewmodelProvider.future);
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
                'Is a list of Country',
                isA<List<Country>>(),
              ),
        ),
      );
    },
  );
}
