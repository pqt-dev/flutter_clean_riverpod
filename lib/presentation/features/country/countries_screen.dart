import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/generated/locale_keys.g.dart';
import 'package:flutter_clean_riverpod/presentation/extensions/app_error_extension.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_state.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/country_viewmodel.dart';
import 'package:flutter_clean_riverpod/presentation/features/country/widget/country_item_view.dart';
import 'package:flutter_clean_riverpod/presentation/features/widgets/app_loader.dart';
import 'package:flutter_clean_riverpod/presentation/features/widgets/error_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountriesScreen extends ConsumerWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(countryViewmodelProvider);
    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          AsyncLoading<CountryState>() => AppLoader(),
          AsyncData<CountryState>(value: CountryStateData(:final countries)) =>
            GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24.0,
                crossAxisSpacing: 24.0,
              ),
              itemBuilder: (context, index) =>
                  CountryItemView(data: countries[index]),
              itemCount: countries.length,
            ),
          AsyncData<CountryState>(value: CountryStateError(:final error)) =>
            ErrorView(
              message: error.localizedMessage,
              onRetry: () => ref.invalidate(countryViewmodelProvider),
            ),
          AsyncError<CountryState>(:final error) => ErrorView(
            message: error is AppError
                ? error.localizedMessage
                : LocaleKeys.error_unexpected.tr(),
            onRetry: () => ref.invalidate(countryViewmodelProvider),
          ),
        },
      ),
    );
  }
}
