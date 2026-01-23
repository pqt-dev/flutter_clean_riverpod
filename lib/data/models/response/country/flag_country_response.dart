import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flag_country_response.freezed.dart';
part 'flag_country_response.g.dart';

@freezed
abstract class FlagCountryResponse with _$FlagCountryResponse {
  const factory FlagCountryResponse({
    String? png,
    String? svg,
  }) = _FlagCountryResponse;

  factory FlagCountryResponse.fromJson(Map<String, dynamic> json) =>
      _$FlagCountryResponseFromJson(json);
}
