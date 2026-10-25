import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../invoices/application/invoices_controller.dart';
import '../application/cart_controller.dart';

/// Collects optional customer/discount, issues the invoice and opens it.
Future<void> showCheckoutSheet(BuildContext context) async {
  final number = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CheckoutSheet(),
  );
  if (number != null && context.mounted) {
    await context.push<void>(AppRoutes.invoice(number));
  }
}

class _CheckoutSheet extends ConsumerStatefulWidget {
  const _CheckoutSheet();

  @override
  ConsumerState<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<_CheckoutSheet> {
  final _customer = TextEditingController();
  final _discount = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _customer.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final navigator = Navigator.of(context);
    final invoice = await ref
        .read(invoicesControllerProvider.notifier)
        .checkout(
          customer: _customer.text,
          discount: parsePrice(_discount.text) ?? 0,
        );
    navigator.pop(invoice.number);
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartTotalProvider);
    final discount = (parsePrice(_discount.text) ?? 0).clamp(0, subtotal);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'صدور فاکتور',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _customer,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'نام خریدار (اختیاری)',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _discount,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'تخفیف به تومان (اختیاری)',
                  prefixIcon: Icon(Icons.local_offer_rounded),
                ),
              ),
              const SizedBox(height: 18),
              _line('جمع کالاها', toman(subtotal)),
              if (discount > 0)
                _line('تخفیف', toman(discount), color: AppColors.danger),
              const Divider(height: 24),
              Row(
                children: [
                  const Text(
                    'مبلغ قابل پرداخت',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  PriceText(subtotal - discount, fontSize: 22),
                ],
              ),
              const SizedBox(height: 22),
              GradientButton(
                label: 'ثبت و نمایش فاکتور',
                icon: Icons.check_circle_rounded,
                onPressed: _submitting || subtotal == 0 ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    ),
  );
}
