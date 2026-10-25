import 'product.dart';

/// Source of truth for the product catalogue.
///
/// Reads are synchronous because implementations are expected to serve them
/// from memory; writes are persisted asynchronously.
abstract interface class ProductRepository {
  List<Product> getAll();

  Product? findByCode(String code);

  Future<void> save(Product product);

  Future<void> delete(String code);
}
