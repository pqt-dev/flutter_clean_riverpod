import 'package:flutter/services.dart';

class APIEndpoint {
  // TODO: Update production URL — currently both environments point to the same URL.
  static const baseUrl = appFlavor == 'develop'
      ? 'https://restcountries.com/v3.1'
      : 'https://restcountries.com/v3.1';

  static const String allCountries = '/all';
}
