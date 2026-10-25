import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../data/local_invoice_repository.dart';
import '../domain/invoice.dart';

/// Issued invoices, newest first.
final invoicesControllerProvider =
    NotifierProvider<InvoicesController, List<Invoice>>(InvoicesController.new);

final invoiceByNumberProvider = Provider.family<Invoice?, int>(
  (ref, number) => ref
      .watch(invoicesControllerProvider)
      .where((i) => i.number == number)
      .firstOrNull,
);

class InvoicesController extends Notifier<List<Invoice>> {
  static const firstInvoiceNumber = 1001;

  @override
  List<Invoice> build() => ref.watch(invoiceRepositoryProvider).getAll();

  /// Turns the current cart into an invoice and empties the cart.
  Future<Invoice> checkout({String customer = '', int discount = 0}) async {
    final items = ref.read(cartControllerProvider);
    if (items.isEmpty) {
      throw StateError('Cannot issue an invoice for an empty cart');
    }

    final lines = [
      // Cart is newest-first; invoices list items in the order they were scanned.
      for (final item in items.reversed)
        InvoiceLine(
          code: item.product.code,
          name: item.product.name,
          unitPrice: item.product.price,
          quantity: item.quantity,
        ),
    ];
    final subtotal = lines.fold(0, (s, l) => s + l.total);
    final invoice = Invoice(
      number: _nextNumber(),
      issuedAt: DateTime.now(),
      customer: customer.trim(),
      discount: discount.clamp(0, subtotal),
      lines: List.unmodifiable(lines),
    );

    final repo = ref.read(invoiceRepositoryProvider);
    await repo.add(invoice);
    state = repo.getAll();
    ref.read(cartControllerProvider.notifier).clear();
    return invoice;
  }

  Future<void> delete(int number) async {
    final repo = ref.read(invoiceRepositoryProvider);
    final pending = repo.delete(number);
    state = repo.getAll();
    await pending;
  }

  int _nextNumber() => state.isEmpty
      ? firstInvoiceNumber
      : state.map((i) => i.number).reduce((a, b) => a > b ? a : b) + 1;
}
