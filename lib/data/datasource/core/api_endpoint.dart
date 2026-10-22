import 'package:flutter/services.dart';

class APIEndpoint {
  static const baseUrl = appFlavor == 'develop'
      ? 'https://example.com'
      : 'https://example.com';
}
