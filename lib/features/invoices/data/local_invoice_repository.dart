import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_provider.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>(
  (ref) => LocalInvoiceRepository(ref.watch(sharedPreferencesProvider)),
);

class LocalInvoiceRepository implements InvoiceRepository {
  LocalInvoiceRepository(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      _cache.addAll(
        (jsonDecode(raw) as List).map(
          (e) => Invoice.fromJson(e as Map<String, Object?>),
        ),
      );
    }
  }

  static const _key = 'invoices.v1';

  final SharedPreferencesWithCache _prefs;
  final List<Invoice> _cache = [];

  @override
  List<Invoice> getAll() => List.unmodifiable(_cache);

  @override
  Future<void> add(Invoice invoice) {
    _cache.insert(0, invoice);
    return _flush();
  }

  @override
  Future<void> delete(int number) {
    _cache.removeWhere((i) => i.number == number);
    return _flush();
  }

  Future<void> _flush() => _prefs.setString(
    _key,
    jsonEncode(_cache.map((i) => i.toJson()).toList()),
  );
}
