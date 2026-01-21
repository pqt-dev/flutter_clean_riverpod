import 'package:flutter_clean_riverpod/data/datasource/remote/api_result.dart';
import 'package:flutter_clean_riverpod/data/models/response/country/country_response.dart';
import 'package:flutter_clean_riverpod/data/repositories/country/country_repository.dart';
import 'package:flutter_clean_riverpod/infrastructure/di/injection.dart';
import 'package:flutter_clean_riverpod/presentation/features/home/home_state.dart';
import 'package:flutter_clean_riverpod/presentation/features/home/home_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_viewmodel_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CountryRepository>()])
void main() {
  late final MockCountryRepository mockRepository;
  setUp(() {
    mockRepository = MockCountryRepository();
    if (GetIt.instance.isRegistered<CountryRepository>()) {
      GetIt.instance.unregister<CountryRepository>();
    }
    GetIt.instance.registerSingleton<CountryRepository>(mockRepository);
  });
  test(
    'Test whether the HomeViewmodel instance is initialized and `initialize()` function is successful',
    () async {
      final container = ProviderContainer();
      final mockResponseSuccess = ApiResult<List<CountryResponse>>.success(
        [
          CountryResponse(),
          CountryResponse(),
        ],
      );
      provideDummy(mockResponseSuccess);
      when(mockRepository.fetchAllCountries()).thenAnswer((_) async => mockResponseSuccess);
      final future = container.read(homeViewmodelProvider.future);
      addTearDown(container.dispose);
      await expectLater(
        future,
        completion(
          isA<HomeState>()
              .having(
                (state) => state.countries.length,
                'List of country has 2 items',
                equals(2),
              )
              .having(
                (state) => state.countries,
                'Is a list of CountryResponse',
                isA<List<CountryResponse>>(),
              ),
        ),
      );
    },
  );
}
