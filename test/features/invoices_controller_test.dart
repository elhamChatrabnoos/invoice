import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/features/cart/application/cart_controller.dart';
import 'package:invoice/features/invoices/application/invoices_controller.dart';
import 'package:invoice/features/products/domain/product.dart';

import '../helpers.dart';

const milk = Product(code: '111', name: 'شیر', price: 48000);
const tea = Product(code: '222', name: 'چای', price: 320000);

void main() {
  setUp(useInMemoryPrefs);

  test('checkout issues a numbered invoice and empties the cart', () async {
    final c = await createContainer();
    addTearDown(c.dispose);
    c.read(cartControllerProvider.notifier)
      ..add(milk, quantity: 2)
      ..add(tea);

    final invoice = await c
        .read(invoicesControllerProvider.notifier)
        .checkout(customer: '  مریم  ', discount: 6000);

    expect(invoice.number, InvoicesController.firstInvoiceNumber);
    expect(invoice.customer, 'مریم');
    expect(invoice.lines.map((l) => l.name), [
      'شیر',
      'چای',
    ], reason: 'lines follow scan order');
    expect(invoice.subtotal, 416000);
    expect(invoice.total, 410000);
    expect(c.read(cartControllerProvider), isEmpty);
    expect(c.read(invoiceByNumberProvider(invoice.number)), same(invoice));
  });

  test('invoice numbers increase and discount is capped', () async {
    final c = await createContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartControllerProvider.notifier);
    final invoices = c.read(invoicesControllerProvider.notifier);

    cart.add(milk);
    await invoices.checkout();
    cart.add(milk);
    final second = await invoices.checkout(discount: 999999);

    expect(second.number, InvoicesController.firstInvoiceNumber + 1);
    expect(second.total, 0);
    expect(c.read(invoicesControllerProvider).first, same(second));
  });

  test('checkout of an empty cart is rejected', () async {
    final c = await createContainer();
    addTearDown(c.dispose);
    expect(
      () => c.read(invoicesControllerProvider.notifier).checkout(),
      throwsStateError,
    );
  });
}
