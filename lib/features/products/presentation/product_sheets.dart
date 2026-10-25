import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../cart/application/cart_controller.dart';
import '../application/products_controller.dart';
import '../domain/product.dart';
import 'category_avatar.dart';

/// Shows a scanned product. Returns the quantity added to the cart, or null.
Future<int?> showProductFoundSheet(BuildContext context, Product product) =>
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductFoundSheet(product: product),
    );

/// Creates (when [product] is null) or edits a product and returns it once
/// saved. [code] pre-fills and locks the barcode; [isNewScan] explains that
/// the scanned code is unknown.
Future<Product?> showProductFormSheet(
  BuildContext context, {
  Product? product,
  String? code,
  bool isNewScan = false,
}) => showModalBottomSheet<Product>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _ProductFormSheet(
    product: product,
    lockedCode: code ?? product?.code,
    isNewScan: isNewScan,
  ),
);

class _ProductFoundSheet extends ConsumerStatefulWidget {
  const _ProductFoundSheet({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductFoundSheet> createState() => _ProductFoundSheetState();
}

class _ProductFoundSheetState extends ConsumerState<_ProductFoundSheet> {
  late Product _product = widget.product;
  int _quantity = 1;

  Future<void> _edit() async {
    final updated = await showProductFormSheet(context, product: _product);
    if (updated != null) setState(() => _product = updated);
  }

  void _addToCart() {
    ref
        .read(cartControllerProvider.notifier)
        .add(_product, quantity: _quantity);
    Navigator.of(context).pop(_quantity);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CategoryAvatar(category: _product.category, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryChip(_product.category),
                      const SizedBox(height: 6),
                      Text(
                        _product.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'ویرایش کالا',
                  onPressed: _edit,
                  icon: const Icon(Icons.edit_rounded, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  fa(_product.code),
                  style: const TextStyle(
                    color: AppColors.muted,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قیمت واحد',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      PriceText(_product.price, fontSize: 26),
                    ],
                  ),
                ),
                QtyStepper(
                  value: _quantity,
                  min: 1,
                  onChanged: (v) => setState(() => _quantity = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'افزودن به سبد – ${toman(_product.price * _quantity)}',
              icon: Icons.add_shopping_cart_rounded,
              onPressed: _addToCart,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(this.category);

  final ProductCategory category;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.teal.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      category.label,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF128A76),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  const _ProductFormSheet({
    this.product,
    this.lockedCode,
    this.isNewScan = false,
  });

  final Product? product;
  final String? lockedCode;
  final bool isNewScan;

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.lockedCode ?? '');
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _price = TextEditingController(
    text: widget.product?.price.toString() ?? '',
  );
  late ProductCategory _category =
      widget.product?.category ?? ProductCategory.general;

  bool get _codeLocked => widget.lockedCode != null;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _scanCode() async {
    final code = await context.push<String>(AppRoutes.pickBarcode);
    if (code != null && mounted) setState(() => _code.text = code);
  }

  String? _validateCode(String? value) {
    final code = toLatinDigits(value ?? '').trim();
    if (code.isEmpty) return 'بارکد را وارد یا اسکن کنید';
    final isNew = widget.product == null;
    if (isNew &&
        !_codeLocked &&
        ref.read(productsControllerProvider.notifier).findByCode(code) !=
            null) {
      return 'کالایی با این بارکد قبلاً ثبت شده است';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final product = Product(
      code: toLatinDigits(_code.text).trim(),
      name: _name.text.trim(),
      price: parsePrice(_price.text)!,
      category: _category,
    );
    final navigator = Navigator.of(context);
    await ref.read(productsControllerProvider.notifier).save(product);
    navigator.pop(product);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
    final price = parsePrice(_price.text);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isNewScan) const _UnknownProductBanner(),
                Text(
                  editing ? 'ویرایش کالا' : 'تعریف کالای جدید',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _code,
                  enabled: !_codeLocked,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'بارکد',
                    prefixIcon: const Icon(Icons.qr_code_rounded),
                    suffixIcon: _codeLocked
                        ? null
                        : IconButton(
                            tooltip: 'اسکن بارکد',
                            onPressed: _scanCode,
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  validator: _validateCode,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _name,
                  autofocus: widget.isNewScan,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'نام کالا',
                    prefixIcon: Icon(Icons.label_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'نام کالا را وارد کنید'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'قیمت (تومان)',
                    prefixIcon: const Icon(Icons.payments_rounded),
                    helperText: price == null ? null : toman(price),
                  ),
                  validator: (v) =>
                      parsePrice(v ?? '') == null ? 'قیمت را وارد کنید' : null,
                ),
                const SizedBox(height: 18),
                const Text(
                  'دسته‌بندی',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in ProductCategory.values)
                      ChoiceChip(
                        label: Text(c.label),
                        avatar: Icon(c.icon, size: 18),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: widget.isNewScan
                      ? 'ذخیره و افزودن به سبد'
                      : 'ذخیرهٔ کالا',
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnknownProductBanner extends StatelessWidget {
  const _UnknownProductBanner();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.amber.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_rounded, color: Color(0xFFB7791F)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'این کالا هنوز ثبت نشده است. نام و قیمت را وارد کنید تا ذخیره و به سبد اضافه شود.',
            style: TextStyle(height: 1.7, fontSize: 13.5),
          ),
        ),
      ],
    ),
  );
}
