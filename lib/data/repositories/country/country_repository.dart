import '../../datasource/remote/api_result.dart';
import '../../models/response/country/country_response.dart';

abstract class CountryRepository {
  Future<ApiResult<List<CountryResponse>>> fetchAllCountries();
}
