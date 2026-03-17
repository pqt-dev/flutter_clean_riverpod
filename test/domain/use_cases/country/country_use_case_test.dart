import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_clean_riverpod/domain/repositories/country/country_repository.dart';
import 'package:flutter_clean_riverpod/domain/use_cases/country/country_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'country_use_case_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CountryRepository>()])
void main() {
  late MockCountryRepository repository;
  late CountryUseCase useCase;

  setUp(() {
    repository = MockCountryRepository();
    useCase = CountryUseCase(repository);
  });

  test('fetchAllCountries delegates to repository and returns Success', () async {
    final countries = [
      Country(name: CountryName(common: 'Vietnam')),
      Country(name: CountryName(common: 'Japan')),
    ];
    final expected = Success(countries);
    provideDummy<Result<List<Country>>>(expected);
    when(repository.fetchAllCountries()).thenAnswer((_) async => expected);

    final result = await useCase.fetchAllCountries();

    expect(result, isA<Success<List<Country>>>());
    expect((result as Success).value, equals(countries));
    verify(repository.fetchAllCountries()).called(1);
  });

  test('fetchAllCountries delegates to repository and returns Failure', () async {
    final expected = Failure(NetworkError());
    provideDummy<Result<List<Country>>>(expected);
    when(repository.fetchAllCountries()).thenAnswer((_) async => expected);

    final result = await useCase.fetchAllCountries();

    expect(result, isA<Failure>());
    expect((result as Failure).error, isA<NetworkError>());
    verify(repository.fetchAllCountries()).called(1);
  });
}
