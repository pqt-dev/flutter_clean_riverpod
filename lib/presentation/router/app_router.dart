import 'package:flutter_clean_riverpod/presentation/counter_screen.dart';
import 'package:flutter_clean_riverpod/presentation/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const CounterScreen(),
      ),
    ],
  );
}
