import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../application/products_controller.dart';
import '../domain/product.dart';
import 'category_avatar.dart';
import 'product_sheets.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _query = '';

  List<Product> _filter(List<Product> products) {
    final q = toLatinDigits(_query.trim());
    if (q.isEmpty) return products;
    return products
        .where((p) => p.name.contains(q) || p.code.contains(q))
        .toList(growable: false);
  }

  Future<void> _delete(Product product) async {
    final confirmed = await confirmDialog(
      context,
      title: 'حذف کالا',
      message: '«${product.name}» از فهرست کالاها حذف شود؟',
      confirmLabel: 'حذف',
    );
    if (confirmed) {
      await ref.read(productsControllerProvider.notifier).delete(product.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(productsControllerProvider);
    final products = _filter(all);
    return Scaffold(
      appBar: AppBar(title: Text('کالاها (${fa(all.length)})')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductFormSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('کالای جدید'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'جستجوی نام یا بارکد…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'کالایی پیدا نشد',
                    message: 'عبارت دیگری را امتحان کنید یا کالای جدید بسازید.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ProductTile(
                      product: products[i],
                      onTap: () =>
                          showProductFormSheet(context, product: products[i]),
                      onDelete: () => _delete(products[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Row(
        children: [
          CategoryAvatar(category: product.category),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  fa(product.code),
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            toman(product.price),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            tooltip: 'حذف',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
