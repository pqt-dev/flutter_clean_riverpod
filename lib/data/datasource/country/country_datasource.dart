import 'package:flutter_clean_riverpod/data/models/country/country_model.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';

/// Abstract interface for country data source.
/// Enables swapping between remote and local implementations.
abstract class CountryDatasource {
  Future<Result<List<CountryModel>>> fetchAllCountries();
}
