import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common.dart';
import '../../cart/application/cart_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/presentation/invoice_tile.dart';
import '../../products/presentation/product_sheets.dart';
import '../../scanner/presentation/scanner_page.dart';

/// Today's sales: (invoice count, total in Toman).
final _todayStatsProvider = Provider<(int, int)>((ref) {
  final now = DateTime.now();
  final today = ref
      .watch(invoicesControllerProvider)
      .where(
        (i) =>
            i.issuedAt.year == now.year &&
            i.issuedAt.month == now.month &&
            i.issuedAt.day == now.day,
      );
  return (today.length, today.fold(0, (s, i) => s + i.total));
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(invoicesControllerProvider).take(3).toList();
    final (todayCount, todaySales) = ref.watch(_todayStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _Header(),
            const SizedBox(height: 20),
            const _CartHeroCard(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt_rounded,
                    color: AppColors.primary,
                    label: 'فاکتورهای امروز',
                    value: fa(todayCount),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up_rounded,
                    color: AppColors.teal,
                    label: 'فروش امروز',
                    value: money(todaySales),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_box_rounded,
                    label: 'تعریف کالا',
                    onTap: () => showProductFormSheet(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.inventory_2_rounded,
                    label: 'فهرست کالاها',
                    onTap: () => context.go(AppRoutes.products),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Text(
                  'آخرین فاکتورها',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (recent.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go(AppRoutes.invoices),
                    child: const Text('همه'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              const SoftCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: AppColors.muted,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'هنوز فاکتوری صادر نشده است',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final invoice in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InvoiceTile(invoice: invoice),
                ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(size: 48, shadow: false),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                appName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              Text(
                jalaliLong(DateTime.now()),
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartHeroCard extends ConsumerWidget {
  const _CartHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -30,
            top: -40,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: .08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سبد فعلی – ${fa(count)} کالا',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              if (count == 0)
                const Text(
                  'سبد خالی است',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else
                PriceText(total, fontSize: 30, color: Colors.white),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => openScanner(context),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('اسکن کالا'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .18),
                      minimumSize: const Size(54, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    tooltip: 'مشاهدهٔ سبد',
                    onPressed: () => context.go(AppRoutes.cart),
                    icon: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
