import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'flag_country_response.dart';
import 'name_country_response.dart';

part 'country_response.freezed.dart';
part 'country_response.g.dart';

@freezed
abstract class CountryResponse with _$CountryResponse {
  const factory CountryResponse({
    NameCountryResponse? name,
    List<String>? capital,
    String? region,
    String? subregion,
    double? area,
    int? population,
    FlagCountryResponse? flags,
  }) = _CountryResponse;

  factory CountryResponse.fromJson(Map<String, dynamic> json) => _$CountryResponseFromJson(json);
}
