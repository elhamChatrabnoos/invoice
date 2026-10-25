import 'invoice.dart';

abstract interface class InvoiceRepository {
  /// All invoices, newest first.
  List<Invoice> getAll();

  Future<void> add(Invoice invoice);

  Future<void> delete(int number);
}
