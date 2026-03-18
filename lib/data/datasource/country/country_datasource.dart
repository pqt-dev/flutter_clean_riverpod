import 'package:flutter_clean_riverpod/domain/core/result.dart';

import '../../models/country/country_model.dart';

/// Abstract interface for country data source.
/// Enables swapping between remote and local implementations.
abstract class CountryDatasource {
  Future<Result<List<CountryModel>>> fetchCountries();
}
