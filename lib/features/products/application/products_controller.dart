import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../data/local_product_repository.dart';
import '../domain/product.dart';

/// The catalogue, sorted by name.
final productsControllerProvider =
    NotifierProvider<ProductsController, List<Product>>(ProductsController.new);

class ProductsController extends Notifier<List<Product>> {
  @override
  List<Product> build() =>
      _sorted(ref.watch(productRepositoryProvider).getAll());

  Product? findByCode(String code) =>
      ref.read(productRepositoryProvider).findByCode(code);

  Future<void> save(Product product) async {
    final repo = ref.read(productRepositoryProvider);
    final pending = repo.save(product);
    state = _sorted(repo.getAll());
    ref.read(cartControllerProvider.notifier).syncProduct(product);
    await pending;
  }

  Future<void> delete(String code) async {
    final repo = ref.read(productRepositoryProvider);
    final pending = repo.delete(code);
    state = _sorted(repo.getAll());
    await pending;
  }

  static List<Product> _sorted(List<Product> products) =>
      [...products]..sort((a, b) => a.name.compareTo(b.name));
}
