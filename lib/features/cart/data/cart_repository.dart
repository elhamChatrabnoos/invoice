import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_provider.dart';
import '../domain/cart_item.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => LocalCartRepository(ref.watch(sharedPreferencesProvider)),
);

/// Persists the open (not yet invoiced) cart so it survives app restarts.
abstract interface class CartRepository {
  List<CartItem> load();

  Future<void> save(List<CartItem> items);
}

class LocalCartRepository implements CartRepository {
  LocalCartRepository(this._prefs);

  static const _key = 'cart.v1';

  final SharedPreferencesWithCache _prefs;

  @override
  List<CartItem> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List)
        .map((e) => CartItem.fromJson(e as Map<String, Object?>))
        .toList(growable: false);
  }

  @override
  Future<void> save(List<CartItem> items) =>
      _prefs.setString(_key, jsonEncode(items.map((i) => i.toJson()).toList()));
}
