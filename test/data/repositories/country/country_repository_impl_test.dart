import 'package:flutter_clean_riverpod/data/datasource/country/country_datasource.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_model.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_name_model.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_flag_model.dart';
import 'package:flutter_clean_riverpod/data/repositories/country/country_repository_impl.dart';
import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'country_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CountryDatasource>()])
void main() {
  late MockCountryDatasource datasource;
  late CountryRepositoryImpl repository;

  setUp(() {
    datasource = MockCountryDatasource();
    repository = CountryRepositoryImpl(datasource);
  });

  group('fetchAllCountries', () {
    test('returns Success with mapped entities when datasource succeeds', () async {
      final models = [
        CountryModel(
          name: CountryNameModel(common: 'Vietnam', official: 'Socialist Republic of Vietnam'),
          flags: CountryFlagModel(png: 'https://flagcdn.com/vn.png'),
          capital: ['Hanoi'],
          region: 'Asia',
          population: 97338579,
        ),
        CountryModel(
          name: CountryNameModel(common: 'Japan'),
          capital: ['Tokyo'],
          region: 'Asia',
        ),
      ];
      provideDummy<Result<List<CountryModel>>>(Success(models));
      when(datasource.fetchCountries()).thenAnswer((_) async => Success(models));

      final result = await repository.fetchAllCountries();

      expect(result, isA<Success<List<Country>>>());
      final countries = (result as Success<List<Country>>).value;
      expect(countries, hasLength(2));
      expect(countries[0].name?.common, equals('Vietnam'));
      expect(countries[0].flags?.png, equals('https://flagcdn.com/vn.png'));
      expect(countries[1].name?.common, equals('Japan'));
      verify(datasource.fetchCountries()).called(1);
    });

    test('returns Success with empty list when datasource returns empty', () async {
      provideDummy<Result<List<CountryModel>>>(Success(<CountryModel>[]));
      when(datasource.fetchCountries()).thenAnswer((_) async => Success([]));

      final result = await repository.fetchAllCountries();

      expect(result, isA<Success<List<Country>>>());
      expect((result as Success<List<Country>>).value, isEmpty);
    });

    test('returns Failure with NetworkError when datasource fails with network error', () async {
      final networkError = NetworkError();
      provideDummy<Result<List<CountryModel>>>(Failure(networkError));
      when(datasource.fetchCountries()).thenAnswer((_) async => Failure(networkError));

      final result = await repository.fetchAllCountries();

      expect(result, isA<Failure>());
      expect((result as Failure).error, isA<NetworkError>());
    });

    test('returns Failure with ServerError when datasource fails with server error', () async {
      final serverError = ServerError(statusCode: 500);
      provideDummy<Result<List<CountryModel>>>(Failure(serverError));
      when(datasource.fetchCountries()).thenAnswer((_) async => Failure(serverError));

      final result = await repository.fetchAllCountries();

      expect(result, isA<Failure>());
      final error = (result as Failure).error;
      expect(error, isA<ServerError>());
      expect((error as ServerError).statusCode, equals(500));
    });

    test('correctly maps model fields to entity fields', () async {
      final model = CountryModel(
        capital: ['Canberra'],
        region: 'Oceania',
        subregion: 'Australia and New Zealand',
        area: 7692024.0,
        population: 25687041,
        name: CountryNameModel(common: 'Australia', official: 'Commonwealth of Australia'),
        flags: CountryFlagModel(
          png: 'https://flagcdn.com/au.png',
          svg: 'https://flagcdn.com/au.svg',
          alt: 'Australian flag',
        ),
      );
      provideDummy<Result<List<CountryModel>>>(Success([model]));
      when(datasource.fetchCountries()).thenAnswer((_) async => Success([model]));

      final result = await repository.fetchAllCountries();

      final country = (result as Success<List<Country>>).value.first;
      expect(country.capital, equals(['Canberra']));
      expect(country.region, equals('Oceania'));
      expect(country.subregion, equals('Australia and New Zealand'));
      expect(country.area, equals(7692024.0));
      expect(country.population, equals(25687041));
      expect(country.name?.common, equals('Australia'));
      expect(country.name?.official, equals('Commonwealth of Australia'));
      expect(country.flags?.png, equals('https://flagcdn.com/au.png'));
      expect(country.flags?.svg, equals('https://flagcdn.com/au.svg'));
      expect(country.flags?.alt, equals('Australian flag'));
    });
  });
}
