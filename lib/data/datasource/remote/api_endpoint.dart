import 'package:flutter/services.dart';

class APIEndpoint {
  static const baseUrl = appFlavor == 'dev'
      ? 'https://restcountries.com/v3.1'
      : 'https://restcountries.com/v3.1';

  static const String allCountries = '/all';
}
