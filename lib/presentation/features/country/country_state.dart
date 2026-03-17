import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_state.freezed.dart';

@freezed
abstract class CountryState with _$CountryState {
  const factory CountryState({
    @Default([]) List<Country> countries,
  }) = _CountryState;
}