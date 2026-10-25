import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/core/utils/format.dart';

void main() {
  test('fa converts Latin digits to Persian', () {
    expect(fa('Invoice 1024'), 'Invoice ۱۰۲۴');
  });

  test('money groups thousands with Persian separator', () {
    expect(money(0), '۰');
    expect(money(950), '۹۵۰');
    expect(money(1250000), '۱٬۲۵۰٬۰۰۰');
    expect(toman(48000), '۴۸٬۰۰۰ تومان');
  });

  test('parsePrice accepts Persian, Arabic and grouped input', () {
    expect(parsePrice('۴۸٬۰۰۰'), 48000);
    expect(parsePrice('٣٠٠'), 300);
    expect(parsePrice('1,500'), 1500);
    expect(parsePrice('abc'), isNull);
  });

  test('jalaliDate formats in the Persian calendar', () {
    expect(jalaliDate(DateTime(2024, 3, 20)), '۱۴۰۳/۰۱/۰۱');
  });
}
