import 'package:flutter_clean_riverpod/data/models/country/country_model.dart';
import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_clean_riverpod/domain/repositories/country/country_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'country_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CountryRepository>()])
void main() {
  final repository = MockCountryRepository();
  test('Fetch data success is successfully.', () async {
    final mockResponseSuccess = Success([Country(), Country()]);
    provideDummy(mockResponseSuccess);
    when(
      repository.fetchAllCountries(),
    ).thenAnswer((_) async => mockResponseSuccess);
    final actual = await repository.fetchAllCountries();
    expect(actual, isA<Result<List<CountryModel>>>());
    expect(
      actual,
      isA<Success<List<CountryModel>>>()
          .having(
            (value) => value.value,
            'Is a list of CountryResponse',
            isA<List<CountryModel>>(),
          )
          .having(
            (value) => value.value.length,
            'Value has 2 items',
            equals(2),
          ),
    );
  });
  test('Fetch data is error.', () async {
    final mockError = Failure(NetworkError());
    provideDummy(mockError);
    when(repository.fetchAllCountries()).thenAnswer((_) async => mockError);
    final actual = await repository.fetchAllCountries();
    expect(actual, isA<Failure>());
  });
}
