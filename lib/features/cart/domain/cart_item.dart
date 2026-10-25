import 'package:flutter/foundation.dart';

import '../../products/domain/product.dart';

@immutable
class CartItem {
  const CartItem({required this.product, required this.quantity})
    : assert(quantity > 0);

  final Product product;
  final int quantity;

  int get total => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) => CartItem(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
  );

  Map<String, Object?> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, Object?> json) => CartItem(
    product: Product.fromJson(json['product']! as Map<String, Object?>),
    quantity: json['quantity']! as int,
  );

  @override
  bool operator ==(Object other) =>
      other is CartItem &&
      other.product == product &&
      other.quantity == quantity;

  @override
  int get hashCode => Object.hash(product, quantity);
}
