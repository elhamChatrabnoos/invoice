import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/domain/product.dart';
import '../data/cart_repository.dart';
import '../domain/cart_item.dart';

/// Items in the open cart, most recently added first.
final cartControllerProvider = NotifierProvider<CartController, List<CartItem>>(
  CartController.new,
);

/// Total number of units in the cart.
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartControllerProvider).fold(0, (s, i) => s + i.quantity),
);

/// Cart total in Toman.
final cartTotalProvider = Provider<int>(
  (ref) => ref.watch(cartControllerProvider).fold(0, (s, i) => s + i.total),
);

class CartController extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => ref.watch(cartRepositoryProvider).load();

  void add(Product product, {int quantity = 1}) {
    final index = state.indexWhere((i) => i.product.code == product.code);
    if (index == -1) {
      _commit([CartItem(product: product, quantity: quantity), ...state]);
    } else {
      final item = state[index];
      _commit(
        [...state]
          ..[index] = item.copyWith(
            product: product,
            quantity: item.quantity + quantity,
          ),
      );
    }
  }

  /// Sets the quantity of [code]; a quantity of zero removes the line.
  void setQuantity(String code, int quantity) {
    if (quantity <= 0) return remove(code);
    _commit([
      for (final i in state)
        i.product.code == code ? i.copyWith(quantity: quantity) : i,
    ]);
  }

  void remove(String code) =>
      _commit(state.where((i) => i.product.code != code).toList());

  void clear() => _commit(const []);

  /// Keeps name/price of cart lines in step with catalogue edits.
  void syncProduct(Product product) {
    if (!state.any((i) => i.product.code == product.code)) return;
    _commit([
      for (final i in state)
        i.product.code == product.code ? i.copyWith(product: product) : i,
    ]);
  }

  void _commit(List<CartItem> next) {
    state = List.unmodifiable(next);
    unawaited(ref.read(cartRepositoryProvider).save(state));
  }
}
