import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../application/invoice_pdf_service.dart';
import '../application/invoices_controller.dart';
import '../domain/invoice.dart';
import 'invoice_receipt.dart';

class InvoiceDetailPage extends ConsumerStatefulWidget {
  const InvoiceDetailPage({super.key, required this.number});

  final int number;

  @override
  ConsumerState<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends ConsumerState<InvoiceDetailPage> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        showToast(
          context,
          'آماده‌سازی فایل با خطا مواجه شد',
          icon: Icons.error_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(Invoice invoice) async {
    final confirmed = await confirmDialog(
      context,
      title: 'حذف فاکتور',
      message: 'فاکتور شمارهٔ ${fa(invoice.number)} برای همیشه حذف شود؟',
      confirmLabel: 'حذف',
    );
    if (!confirmed || !mounted) return;
    context.pop();
    await ref.read(invoicesControllerProvider.notifier).delete(invoice.number);
  }

  @override
  Widget build(BuildContext context) {
    final invoice = ref.watch(invoiceByNumberProvider(widget.number));
    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'فاکتور پیدا نشد',
          message: 'ممکن است این فاکتور حذف شده باشد.',
        ),
      );
    }
    final pdf = ref.read(invoicePdfServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('فاکتور ${fa(invoice.number)}'),
        actions: [
          IconButton(
            tooltip: 'حذف فاکتور',
            onPressed: () => _delete(invoice),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: InvoiceReceipt(invoice: invoice),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: _busy
                      ? null
                      : () => _run(() => pdf.shareInvoice(invoice)),
                  child: const Icon(Icons.share_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'چاپ فاکتور',
                  icon: Icons.print_rounded,
                  onPressed: _busy
                      ? null
                      : () => _run(() => pdf.printInvoice(invoice)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
