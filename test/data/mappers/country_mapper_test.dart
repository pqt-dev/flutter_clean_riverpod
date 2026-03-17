import 'package:flutter_clean_riverpod/data/mappers/country_mapper.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_flag_model.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_model.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_name_model.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryModelMapper', () {
    test('toEntity() maps all fields correctly', () {
      final model = CountryModel(
        capital: ['Hanoi'],
        region: 'Asia',
        subregion: 'South-Eastern Asia',
        area: 331212.0,
        population: 97338579,
        name: CountryNameModel(common: 'Vietnam', official: 'Socialist Republic of Vietnam'),
        flags: CountryFlagModel(
          png: 'https://flagcdn.com/w320/vn.png',
          svg: 'https://flagcdn.com/vn.svg',
          alt: 'Flag of Vietnam',
        ),
      );

      final entity = model.toEntity();

      expect(entity, isA<Country>());
      expect(entity.capital, equals(['Hanoi']));
      expect(entity.region, equals('Asia'));
      expect(entity.subregion, equals('South-Eastern Asia'));
      expect(entity.area, equals(331212.0));
      expect(entity.population, equals(97338579));
      expect(entity.name?.common, equals('Vietnam'));
      expect(entity.name?.official, equals('Socialist Republic of Vietnam'));
      expect(entity.flags?.png, equals('https://flagcdn.com/w320/vn.png'));
      expect(entity.flags?.svg, equals('https://flagcdn.com/vn.svg'));
      expect(entity.flags?.alt, equals('Flag of Vietnam'));
    });

    test('toEntity() handles null fields', () {
      final model = CountryModel();

      final entity = model.toEntity();

      expect(entity.capital, isNull);
      expect(entity.region, isNull);
      expect(entity.subregion, isNull);
      expect(entity.area, isNull);
      expect(entity.population, isNull);
      expect(entity.name, isNull);
      expect(entity.flags, isNull);
    });

    test('toEntity() handles partial model (name only)', () {
      final model = CountryModel(
        name: CountryNameModel(common: 'Japan'),
      );

      final entity = model.toEntity();

      expect(entity.name?.common, equals('Japan'));
      expect(entity.name?.official, isNull);
      expect(entity.flags, isNull);
    });

    test('toEntity() handles model with multiple capitals', () {
      final model = CountryModel(
        capital: ['Pretoria', 'Bloemfontein', 'Cape Town'],
        name: CountryNameModel(common: 'South Africa'),
      );

      final entity = model.toEntity();

      expect(entity.capital, hasLength(3));
      expect(entity.capital, contains('Pretoria'));
    });
  });

  group('CountryNameModelMapper', () {
    test('toEntity() maps name correctly', () {
      final model = CountryNameModel(common: 'France', official: 'French Republic');
      final entity = model.toEntity();

      expect(entity, isA<CountryName>());
      expect(entity.common, equals('France'));
      expect(entity.official, equals('French Republic'));
    });

    test('toEntity() handles null values', () {
      final model = CountryNameModel();
      final entity = model.toEntity();

      expect(entity.common, isNull);
      expect(entity.official, isNull);
    });
  });

  group('CountryFlagModelMapper', () {
    test('toEntity() maps flag correctly', () {
      final model = CountryFlagModel(
        png: 'https://flagcdn.com/w320/fr.png',
        svg: 'https://flagcdn.com/fr.svg',
        alt: 'Flag of France',
      );
      final entity = model.toEntity();

      expect(entity, isA<CountryFlag>());
      expect(entity.png, equals('https://flagcdn.com/w320/fr.png'));
      expect(entity.svg, equals('https://flagcdn.com/fr.svg'));
      expect(entity.alt, equals('Flag of France'));
    });

    test('toEntity() handles null values', () {
      final model = CountryFlagModel();
      final entity = model.toEntity();

      expect(entity.png, isNull);
      expect(entity.svg, isNull);
      expect(entity.alt, isNull);
    });
  });
}
