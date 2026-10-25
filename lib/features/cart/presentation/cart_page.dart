import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../products/presentation/category_avatar.dart';
import '../../scanner/presentation/scanner_page.dart';
import '../application/cart_controller.dart';
import '../domain/cart_item.dart';
import 'checkout_sheet.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDialog(
      context,
      title: 'خالی کردن سبد',
      message: 'همهٔ کالاهای سبد حذف شوند؟',
      confirmLabel: 'خالی کن',
    );
    if (confirmed) ref.read(cartControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('سبد خرید'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'خالی کردن سبد',
              onPressed: () => _clear(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'سبد خرید خالی است',
              message: 'بارکد کالاها را اسکن کنید تا به سبد اضافه شوند.',
              action: SizedBox(
                width: 220,
                child: GradientButton(
                  label: 'شروع اسکن',
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: () => openScanner(context),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CartLine(
                      key: ValueKey(items[i].product.code),
                      item: items[i],
                    ),
                  ),
                ),
                const _CartSummary(),
              ],
            ),
    );
  }
}

class _CartLine extends ConsumerWidget {
  const _CartLine({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartControllerProvider.notifier);
    return Dismissible(
      key: ValueKey('dismiss-${item.product.code}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(item.product.code),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CategoryAvatar(category: item.product.category, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'واحد: ${toman(item.product.price)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    toman(item.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            QtyStepper(
              compact: true,
              value: item.quantity,
              onChanged: (q) => cart.setQuantity(item.product.code, q),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends ConsumerWidget {
  const _CartSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'جمع کل (${fa(count)} کالا)',
                style: const TextStyle(color: AppColors.muted),
              ),
              const Spacer(),
              PriceText(total, fontSize: 22),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => openScanner(context),
                  child: const Icon(Icons.qr_code_scanner_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'صدور فاکتور',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () => showCheckoutSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
