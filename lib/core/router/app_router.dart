import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cart_page.dart';
import '../../features/home/presentation/dashboard_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/invoices/presentation/invoice_detail_page.dart';
import '../../features/invoices/presentation/invoices_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/products/presentation/products_page.dart';
import '../../features/scanner/presentation/scanner_page.dart';
import '../../features/splash/splash_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const cart = '/cart';
  static const invoices = '/invoices';
  static const products = '/products';

  /// Full-screen scanner. Add `?pick=1` to only return the scanned code.
  static const scan = '/scan';
  static const pickBarcode = '/scan?pick=1';

  static String invoice(int number) => '/invoice/$number';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) => _fade(state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.scan,
        builder: (_, state) =>
            ScannerPage(pickOnly: state.uri.queryParameters['pick'] == '1'),
      ),
      GoRoute(
        path: '/invoice/:number',
        builder: (_, state) => InvoiceDetailPage(
          number: int.parse(state.pathParameters['number']!),
        ),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (_, state, shell) => _fade(state, HomeShell(shell: shell)),
        branches: [
          for (final (path, page) in const [
            (AppRoutes.home, DashboardPage()),
            (AppRoutes.cart, CartPage()),
            (AppRoutes.invoices, InvoicesPage()),
            (AppRoutes.products, ProductsPage()),
          ])
            StatefulShellBranch(
              routes: [GoRoute(path: path, builder: (_, _) => page)],
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

Page<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage(
  key: state.pageKey,
  transitionDuration: const Duration(milliseconds: 500),
  child: child,
  transitionsBuilder: (_, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);
