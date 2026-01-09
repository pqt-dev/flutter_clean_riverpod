import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/ui/core/app_bar_view.dart';
import 'package:flutter_clean_riverpod/presentation/ui/core/not_found_data_view.dart';
import 'package:flutter_clean_riverpod/presentation/ui/home/home_controller.dart';
import 'package:flutter_clean_riverpod/presentation/ui/home/home_state.dart';
import 'package:flutter_clean_riverpod/presentation/ui/home/widget/country_item_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    return Scaffold(
      appBar: AppBarView(
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Icon(Icons.menu),
            );
          },
        ),
        title: 'LIST OF COUNTRIES',
        titleColor: Colors.white,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: switch (state) {
          AsyncLoading<HomeState>() => SpinKitDancingSquare(
            color: Colors.orange,
          ),
          AsyncData<HomeState>() => GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 24.0,
              crossAxisSpacing: 24.0,
            ),
            itemBuilder: (context, index) => CountryItemView(data: state.value.countries[index]),
            itemCount: state.value.countries.length,
          ),
          AsyncError<HomeState>() => NotFoundDataView(),
        },
      ),
    );
  }
}
