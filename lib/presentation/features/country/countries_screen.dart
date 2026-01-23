import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_loader.dart';
import 'country_state.dart';
import 'country_viewmodel.dart';
import 'widget/country_item_view.dart';

class CountriesScreen extends ConsumerWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(countryViewmodelProvider);
    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          AsyncLoading<CountryState>() => AppLoader(),
          AsyncData<CountryState>(:final value) => GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 24.0,
              crossAxisSpacing: 24.0,
            ),
            itemBuilder: (context, index) => CountryItemView(data: value.countries[index]),
            itemCount: value.countries.length,
          ),
          AsyncError<CountryState>() => const SizedBox.shrink(),
        },
      ),
    );
  }
}
