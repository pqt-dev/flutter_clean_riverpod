import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';

abstract class CountryRepository {
  Future<Result<List<Country>>> fetchAllCountries();
}
