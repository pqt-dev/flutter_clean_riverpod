import 'package:flutter_clean_riverpod/data/core/api_result.dart';
import 'package:flutter_clean_riverpod/data/repository/country/country_repository.dart';
import 'package:flutter_clean_riverpod/data/response/country/country_response.dart';
import 'package:flutter_clean_riverpod/presentation/ui/home/home_controller.dart';
import 'package:flutter_clean_riverpod/presentation/ui/home/home_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CountryResponse>(),
  MockSpec<CountryRepository>(),
])
void main() {
  ProviderContainer createContainer({
    ProviderContainer? parent,
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) {
    // Create a ProviderContainer, and optionally allow specifying parameters.
    final container = ProviderContainer(
      parent: parent,
      overrides: overrides,
      observers: observers,
    );

    // When the test ends, dispose the container.
    addTearDown(container.dispose);

    return container;
  }

  late final ProviderContainer container;
  late final MockCountryRepository mockRepository;
  setUpAll(() {
    mockRepository = MockCountryRepository();
    container = createContainer(
      // We can specify a list of providers to mock:
      overrides: [
        // In this case, we are mocking "exampleProvider".
        homeControllerProvider.overrideWith(
          () {
            return HomeController(
              mockRepository,
            );
          },
        ),
      ],
    );
  });

  test(
    'Test whether the HomeController instance is initialized and `initialize()` function is successful',
    () async {
      final mockResponseSuccess = ApiResult<List<CountryResponse>>.success(
        [
          MockCountryResponse(),
          MockCountryResponse(),
        ],
      );
      provideDummy(mockResponseSuccess);
      when(
        mockRepository.fetchAllCountries(),
      ).thenAnswer(
        (_) async {
          return mockResponseSuccess;
        },
      );
      final initializeState = container.read(homeControllerProvider.future);
      await expectLater(
        initializeState,
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
