import 'package:flutter_clean_riverpod/data/datasource/remote/api_result.dart';
import 'package:flutter_clean_riverpod/data/error/api_error.dart';
import 'package:flutter_clean_riverpod/data/models/response/country/country_response.dart';
import 'package:flutter_clean_riverpod/data/repositories/country/country_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'country_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CountryRepository>()])
void main() {
  final repository = MockCountryRepository();
  test('Fetch data success is successfully.', () async {
    final mockResponseSuccess = ApiResult<List<CountryResponse>>.success([
      CountryResponse(),
      CountryResponse(),
    ]);
    provideDummy(mockResponseSuccess);
    when(
      repository.fetchAllCountries(),
    ).thenAnswer((_) async => mockResponseSuccess);
    final actual = await repository.fetchAllCountries();
    expect(actual, isA<ApiResult<List<CountryResponse>>>());
    expect(
      actual,
      isA<Success<List<CountryResponse>>>()
          .having(
            (value) => value.value,
            'Is a list of CountryResponse',
            isA<List<CountryResponse>>(),
          )
          .having(
            (value) => value.value.length,
            'Value has 2 items',
            equals(2),
          ),
    );
  });
  test('Fetch data is error.', () async {
    final mockError = ApiResult<List<CountryResponse>>.failed(InternetError());
    provideDummy(mockError);
    when(repository.fetchAllCountries()).thenAnswer((_) async => mockError);
    final actual = await repository.fetchAllCountries();
    expect(actual, isA<Failure>());
  });
}
