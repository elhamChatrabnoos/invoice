import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/features/cart/application/cart_controller.dart';
import 'package:invoice/features/products/application/products_controller.dart';
import 'package:invoice/features/products/domain/product.dart';

import '../helpers.dart';

const milk = Product(code: '111', name: 'شیر', price: 48000);
const tea = Product(code: '222', name: 'چای', price: 320000);

void main() {
  setUp(useInMemoryPrefs);

  test('adding the same product merges quantities', () async {
    final c = await createContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartControllerProvider.notifier);

    cart
      ..add(milk)
      ..add(tea, quantity: 2)
      ..add(milk);

    final items = c.read(cartControllerProvider);
    expect(items.map((i) => i.product.code), ['222', '111']);
    expect(items.last.quantity, 2);
    expect(c.read(cartCountProvider), 4);
    expect(c.read(cartTotalProvider), 2 * 48000 + 2 * 320000);
  });

  test('setting quantity to zero removes the line', () async {
    final c = await createContainer();
    addTearDown(c.dispose);
    c.read(cartControllerProvider.notifier)
      ..add(milk)
      ..setQuantity(milk.code, 0);
    expect(c.read(cartControllerProvider), isEmpty);
  });

  test('cart survives an app restart', () async {
    final prefs = await createPrefs();
    final first = await createContainer(prefs: prefs);
    first.read(cartControllerProvider.notifier).add(tea, quantity: 3);
    first.dispose();
    await pumpEventQueue();

    final second = await createContainer(prefs: prefs);
    addTearDown(second.dispose);
    expect(second.read(cartControllerProvider).single.quantity, 3);
  });

  test('editing a product updates its price in the cart', () async {
    final c = await createContainer();
    addTearDown(c.dispose);
    c.read(cartControllerProvider.notifier).add(milk, quantity: 2);

    await c
        .read(productsControllerProvider.notifier)
        .save(milk.copyWith(price: 50000));

    expect(c.read(cartTotalProvider), 100000);
  });
}
