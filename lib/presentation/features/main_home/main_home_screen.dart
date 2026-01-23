import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/generated/locale_keys.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            label: LocaleKeys.home.tr(context: context),
            icon: Padding(
              padding: .all(2.0),
              child: Icon(Icons.home_outlined),
            ),
          ),
          BottomNavigationBarItem(
            label: LocaleKeys.search.tr(context: context),
            icon: Padding(
              padding: .all(2.0),
              child: Icon(Icons.search_outlined),
            ),
          ),
          BottomNavigationBarItem(
            label: LocaleKeys.favourite.tr(context: context),
            icon: Padding(
              padding: .all(2.0),
              child: Icon(Icons.favorite_outline),
            ),
          ),
          BottomNavigationBarItem(
            label: LocaleKeys.setting.tr(context: context),
            icon: Padding(
              padding: .all(2.0),
              child: Icon(Icons.settings_outlined),
            ),
          ),
        ],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        unselectedFontSize: 12,
        selectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        onTap: (int index) => navigationShell.goBranch(index),
      ),
    );
  }
}
