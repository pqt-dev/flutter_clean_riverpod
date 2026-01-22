import 'package:flutter/foundation.dart';
import 'package:flutter_clean_riverpod/data/models/response/country/country_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_state.freezed.dart';

@freezed
abstract class CountryState with _$CountryState {
  const factory CountryState({
    @Default([]) List<CountryResponse> countries,
  }) = _CountryState;
}