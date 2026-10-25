import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../application/invoices_controller.dart';
import 'invoice_tile.dart';

class InvoicesPage extends ConsumerWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          invoices.isEmpty ? 'فاکتورها' : 'فاکتورها (${fa(invoices.length)})',
        ),
      ),
      body: invoices.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'هنوز فاکتوری ندارید',
              message:
                  'پس از اسکن کالاها، از سبد خرید فاکتور صادر کنید.\nفاکتورها اینجا ذخیره می‌شوند تا بعداً چاپشان کنید.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: invoices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => InvoiceTile(invoice: invoices[i]),
            ),
    );
  }
}
