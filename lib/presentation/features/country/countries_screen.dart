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
          AsyncError<CountryState>(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.0, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16.0),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(countryViewmodelProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}

