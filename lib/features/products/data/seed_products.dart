import '../domain/product.dart';

/// Sample catalogue so the app is usable on first launch. Scanning an unknown
/// barcode lets the user register the real product.
const seedProducts = [
  Product(
    code: '6260100500018',
    name: 'شیر کم‌چرب ۱ لیتری',
    price: 48000,
    category: ProductCategory.dairy,
  ),
  Product(
    code: '6260100500025',
    name: 'ماست پرچرب ۹۰۰ گرمی',
    price: 72000,
    category: ProductCategory.dairy,
  ),
  Product(
    code: '6260100500032',
    name: 'پنیر سفید ۴۰۰ گرمی',
    price: 95000,
    category: ProductCategory.dairy,
  ),
  Product(
    code: '6261107000012',
    name: 'برنج ایرانی ۵ کیلویی',
    price: 1250000,
    category: ProductCategory.grocery,
  ),
  Product(
    code: '6261107000029',
    name: 'روغن مایع ۱.۵ لیتری',
    price: 185000,
    category: ProductCategory.grocery,
  ),
  Product(
    code: '6261107000036',
    name: 'ماکارونی ۵۰۰ گرمی',
    price: 42000,
    category: ProductCategory.grocery,
  ),
  Product(
    code: '6261107000043',
    name: 'رب گوجه‌فرنگی ۸۰۰ گرمی',
    price: 110000,
    category: ProductCategory.grocery,
  ),
  Product(
    code: '6262200300015',
    name: 'چای سیاه ۴۵۰ گرمی',
    price: 320000,
    category: ProductCategory.beverage,
  ),
  Product(
    code: '6262200300022',
    name: 'آب معدنی ۱.۵ لیتری',
    price: 15000,
    category: ProductCategory.beverage,
  ),
  Product(
    code: '6262200300039',
    name: 'دوغ گازدار ۱.۵ لیتری',
    price: 38000,
    category: ProductCategory.beverage,
  ),
  Product(
    code: '6263300100017',
    name: 'بیسکویت ساقه‌طلایی',
    price: 18000,
    category: ProductCategory.snack,
  ),
  Product(
    code: '6263300100024',
    name: 'شکلات تلخ ۷۰٪',
    price: 89000,
    category: ProductCategory.snack,
  ),
  Product(
    code: '6264400200014',
    name: 'مایع ظرفشویی ۱ لیتری',
    price: 76000,
    category: ProductCategory.cleaning,
  ),
  Product(
    code: '6264400200021',
    name: 'دستمال کاغذی ۱۰۰ برگ',
    price: 54000,
    category: ProductCategory.cleaning,
  ),
];
