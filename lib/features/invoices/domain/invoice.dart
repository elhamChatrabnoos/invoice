import 'package:flutter/foundation.dart';

/// A frozen line on an issued invoice; later catalogue edits don't change it.
@immutable
class InvoiceLine {
  const InvoiceLine({
    required this.code,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String code;
  final String name;
  final int unitPrice;
  final int quantity;

  int get total => unitPrice * quantity;

  Map<String, Object?> toJson() => {
    'code': code,
    'name': name,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };

  factory InvoiceLine.fromJson(Map<String, Object?> json) => InvoiceLine(
    code: json['code']! as String,
    name: json['name']! as String,
    unitPrice: json['unitPrice']! as int,
    quantity: json['quantity']! as int,
  );
}

@immutable
class Invoice {
  const Invoice({
    required this.number,
    required this.issuedAt,
    required this.lines,
    this.customer = '',
    this.discount = 0,
  });

  final int number;
  final DateTime issuedAt;
  final List<InvoiceLine> lines;
  final String customer;

  /// Discount in Toman, never more than [subtotal].
  final int discount;

  int get subtotal => lines.fold(0, (sum, l) => sum + l.total);
  int get total => subtotal - discount.clamp(0, subtotal);
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  Map<String, Object?> toJson() => {
    'number': number,
    'issuedAt': issuedAt.toIso8601String(),
    'lines': lines.map((l) => l.toJson()).toList(),
    'customer': customer,
    'discount': discount,
  };

  factory Invoice.fromJson(Map<String, Object?> json) => Invoice(
    number: json['number']! as int,
    issuedAt: DateTime.parse(json['issuedAt']! as String),
    lines: (json['lines']! as List)
        .map((e) => InvoiceLine.fromJson(e as Map<String, Object?>))
        .toList(growable: false),
    customer: (json['customer'] as String?) ?? '',
    discount: (json['discount'] as int?) ?? 0,
  );
}
