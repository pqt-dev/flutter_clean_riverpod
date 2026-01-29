import 'package:flutter_clean_riverpod/data/mappers/country_mapper.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/core/result.dart';
import '../../../domain/repositories/country/country_repository.dart';
import '../../datasource/country/country_datasource_remote.dart';

@LazySingleton(as: CountryRepository)
class CountryRepositoryImpl implements CountryRepository {
  final CountryDatasourceRemote remoteDatasource;

  CountryRepositoryImpl(this.remoteDatasource);

  @override
  Future<Result<List<Country>>> fetchAllCountries() async {
    final result = await remoteDatasource.fetchCountries();
    return switch (result) {
      Success(value: final models) => Success(models.map((e) => e.toEntity()).toList()),
      Failure(error: final error) => Failure(error),
    };
  }
}
