import 'package:shamsi_date/shamsi_date.dart';

const _faDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Converts Latin digits in [value] to Persian digits.
String fa(Object value) => value.toString().replaceAllMapped(
  RegExp(r'\d'),
  (m) => _faDigits[int.parse(m[0]!)],
);

/// Converts Persian/Arabic digits to Latin so user input can be parsed.
String toLatinDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(rune - 0x06F0 + 0x30);
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(rune - 0x0660 + 0x30);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Parses a price typed by the user (any digit set, separators ignored).
int? parsePrice(String input) {
  final digits = toLatinDigits(input).replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? null : int.tryParse(digits);
}

/// 1250000 -> ۱٬۲۵۰٬۰۰۰
String money(int value) {
  final negative = value < 0;
  final s = value.abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write('٬');
    out.write(s[i]);
  }
  return '${negative ? '−' : ''}${fa(out)}';
}

String toman(int value) => '${money(value)} تومان';

String jalaliDate(DateTime d) {
  final f = Jalali.fromDateTime(d).formatter;
  return fa('${f.yyyy}/${f.mm}/${f.dd}');
}

String jalaliLong(DateTime d) {
  final f = Jalali.fromDateTime(d).formatter;
  return '${f.wN} ${fa(f.d)} ${f.mN} ${fa(f.yyyy)}';
}

String clock(DateTime d) => fa(
  '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
);
