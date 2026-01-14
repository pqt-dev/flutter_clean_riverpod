import 'package:flutter_clean_riverpod/presentation/router/app_routes.dart';
import 'package:flutter_clean_riverpod/presentation/ui/home/home_screen.dart';
import 'package:flutter_clean_riverpod/presentation/ui/main_home/main_home_screen.dart';
import 'package:flutter_clean_riverpod/presentation/ui/setting/nested_setting_screen.dart';
import 'package:go_router/go_router.dart';

import '../ui/favourite/favourite_screen.dart';
import '../ui/search/search_screen.dart';
import '../ui/setting/setting_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainHomeScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favourite,
                builder: (context, state) => FavouriteScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.setting,
                builder: (context, state) => SettingScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.detailSetting,
                    builder: (context, state) => NestedSettingScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
