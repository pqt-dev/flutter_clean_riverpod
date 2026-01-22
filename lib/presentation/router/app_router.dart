import 'package:go_router/go_router.dart';

import '../features/country/countries_screen.dart';
import '../features/favourite/favourite_screen.dart';
import '../features/home/home_screen.dart';
import '../features/main_home/main_home_screen.dart';
import '../features/search/search_screen.dart';
import '../features/setting/setting_screen.dart';
import 'app_routes.dart';

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
                routes: [
                  GoRoute(
                    path: AppRoutes.countries,
                    builder: (context, state) => CountriesScreen(),
                  ),
                ],
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
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
