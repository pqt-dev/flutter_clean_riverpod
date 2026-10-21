import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
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

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        countryUseCaseProvider.overrideWithValue(countryUseCase),
      ],
    );
  }

  group('build (initial fetch)', () {
    test('returns CountryStateData when use case returns Success', () async {
      final mockResponseSuccess = Success([Country(), Country()]);
      provideDummy<Result<List<Country>>>(mockResponseSuccess);
      when(
        countryUseCase.fetchAllCountries(),
      ).thenAnswer((_) async => mockResponseSuccess);

      final container = createContainer();
      addTearDown(container.dispose);

      final future = container.read(countryViewmodelProvider.future);
      await expectLater(
        future,
        completion(
          isA<CountryStateData>()
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
      verify(countryUseCase.fetchAllCountries()).called(1);
    });

    test('returns CountryStateError when use case returns Failure', () async {
      const error = NetworkError();
      const mockResponseFailure = Failure(error);
      provideDummy<Result<List<Country>>>(mockResponseFailure);
      when(
        countryUseCase.fetchAllCountries(),
      ).thenAnswer((_) async => mockResponseFailure);

      final container = createContainer();
      addTearDown(container.dispose);

      final future = container.read(countryViewmodelProvider.future);
      await expectLater(
        future,
        completion(
          isA<CountryStateError>().having(
            (state) => state.error,
            'error is the AppError from use case',
            same(error),
          ),
        ),
      );
      verify(countryUseCase.fetchAllCountries()).called(1);
    });
  });
}
