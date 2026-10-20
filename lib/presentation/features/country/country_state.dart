import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_state.freezed.dart';

@freezed
sealed class CountryState with _$CountryState {
  const factory CountryState.data({@Default([]) List<Country> countries}) =
      CountryStateData;
  const factory CountryState.error(AppError error) = CountryStateError;
}
