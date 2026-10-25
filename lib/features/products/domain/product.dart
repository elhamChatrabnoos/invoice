import 'package:flutter/foundation.dart';

@immutable
class Product {
  const Product({
    required this.code,
    required this.name,
    required this.price,
    this.category = ProductCategory.general,
  });

  /// Barcode value; unique identifier of the product.
  final String code;
  final String name;

  /// Unit price in Toman.
  final int price;
  final ProductCategory category;

  Product copyWith({String? name, int? price, ProductCategory? category}) =>
      Product(
        code: code,
        name: name ?? this.name,
        price: price ?? this.price,
        category: category ?? this.category,
      );

  Map<String, Object?> toJson() => {
    'code': code,
    'name': name,
    'price': price,
    'category': category.name,
  };

  factory Product.fromJson(Map<String, Object?> json) => Product(
    code: json['code']! as String,
    name: json['name']! as String,
    price: json['price']! as int,
    category: ProductCategory.fromName(json['category'] as String?),
  );

  @override
  bool operator ==(Object other) =>
      other is Product &&
      other.code == code &&
      other.name == name &&
      other.price == price &&
      other.category == category;

  @override
  int get hashCode => Object.hash(code, name, price, category);
}

enum ProductCategory {
  dairy('لبنیات و بستنی'),
  snack('تنقلات'),
  beverage('نوشیدنی'),
  grocery('خواربار و نان'),
  produce('میوه و سبزیجات'),
  hygiene('آرایشی و بهداشتی'),
  baby('کودک و نوزاد'),
  breakfast('صبحانه'),
  condiment('چاشنی و افزودنی'),
  canned('کنسرو، غذای آماده و منجمد'),
  protein('پروتئین و تخم‌مرغ'),
  nutsAndSweets('خشکبار، دسر و شیرینی'),
  cleaning('دستمال و شوینده'),
  general('عمومی');

  const ProductCategory(this.label);

  final String label;

  static ProductCategory fromName(String? name) =>
      values.where((c) => c.name == name).firstOrNull ?? general;
}
