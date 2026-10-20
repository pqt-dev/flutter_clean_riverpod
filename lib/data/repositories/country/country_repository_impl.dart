import 'package:flutter_clean_riverpod/data/datasource/country/country_datasource.dart';
import 'package:flutter_clean_riverpod/data/mappers/country_mapper.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_clean_riverpod/domain/repositories/country/country_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CountryRepository)
class CountryRepositoryImpl implements CountryRepository {
  final CountryDatasource remoteDatasource;

  CountryRepositoryImpl(this.remoteDatasource);

  @override
  Future<Result<List<Country>>> fetchAllCountries() async {
    final result = await remoteDatasource.fetchAllCountries();
    return switch (result) {
      Success(value: final models) => Success(
        models.map((e) => e.toEntity()).toList(),
      ),
      Failure(error: final error) => Failure(error),
    };
  }
}
