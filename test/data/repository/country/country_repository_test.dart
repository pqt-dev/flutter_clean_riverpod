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
    provideDummy<Result<List<Country>>>(mockResponseSuccess);
    when(
      repository.fetchAllCountries(),
    ).thenAnswer((_) async => mockResponseSuccess);
    final actual = await repository.fetchAllCountries();
    expect(actual, isA<Result<List<Country>>>());
    expect(
      actual,
      isA<Success<List<Country>>>()
          .having(
            (value) => value.value,
            'Is a list of Country',
            isA<List<Country>>(),
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
    provideDummy<Result<List<Country>>>(mockError);
    when(repository.fetchAllCountries()).thenAnswer((_) async => mockError);
    provideDummy(Failure(ServerError()));
    final actual = await repository.fetchAllCountries();
    expect(actual, isA<Failure>());
  });
}
