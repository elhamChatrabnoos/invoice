import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../cart/application/cart_controller.dart';

/// Bottom-navigation scaffold hosting the four main tabs.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text(fa(cartCount)),
              backgroundColor: AppColors.teal,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text(fa(cartCount)),
              backgroundColor: AppColors.teal,
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'سبد خرید',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'فاکتورها',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'کالاها',
          ),
        ],
      ),
    );
  }
}
