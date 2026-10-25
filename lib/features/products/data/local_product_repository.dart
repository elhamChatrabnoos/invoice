import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_provider.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';
import 'seed_products.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => LocalProductRepository(ref.watch(sharedPreferencesProvider)),
);

class LocalProductRepository implements ProductRepository {
  LocalProductRepository(this._prefs) {
    final raw = _prefs.getString(_key);
    final products = raw == null
        ? seedProducts
        : (jsonDecode(raw) as List).map(
            (e) => Product.fromJson(e as Map<String, Object?>),
          );
    _cache = {for (final p in products) p.code: p};
  }

  static const _key = 'products.v1';

  final SharedPreferencesWithCache _prefs;
  late final Map<String, Product> _cache;

  @override
  List<Product> getAll() => List.unmodifiable(_cache.values);

  @override
  Product? findByCode(String code) => _cache[code.trim()];

  @override
  Future<void> save(Product product) {
    _cache[product.code] = product;
    return _flush();
  }

  @override
  Future<void> delete(String code) {
    _cache.remove(code);
    return _flush();
  }

  Future<void> _flush() => _prefs.setString(
    _key,
    jsonEncode(_cache.values.map((p) => p.toJson()).toList()),
  );
}
