import '../../datasource/remote/api_client.dart';
import '../../datasource/remote/api_endpoint.dart';
import '../../datasource/remote/api_result.dart';
import '../../models/response/country/country_response.dart';
import 'country_repository.dart';

class CountryRepositoryImpl implements CountryRepository {
  final ApiClient client;

  CountryRepositoryImpl(this.client);

  @override
  Future<ApiResult<List<CountryResponse>>> fetchAllCountries() {
    return client.request(
        endpoint: APIEndpoint.allCountries,
        method: ApiMethod.get,
        queryParameters: {
          'fields': [
            'name',
            'flags',
            'capital',
            'area',
            'region',
            'subregion',
            'population',
            'postalCode',
            'timezones',
            'borders',
          ],
        },
        decoder: (data) => (data as List<dynamic>)
            .map((element) => CountryResponse.fromJson(element))
            .toList());
  }
}
