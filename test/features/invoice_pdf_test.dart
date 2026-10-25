import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/features/invoices/application/invoice_pdf_service.dart';
import 'package:invoice/features/invoices/domain/invoice.dart';

/// Serves assets straight from the project directory.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());
}

void main() {
  test('builds a Persian invoice PDF', () async {
    final service = InvoicePdfService(
      bundle: _DiskBundle(),
      // 1×1 transparent PNG; rendering the real logo needs a GPU-backed engine.
      logo: () async => Uint8List.fromList(const [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0,
        0,
        0,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0,
        0,
        0,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0,
        1,
        0,
        0,
        5,
        0,
        1,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0,
        0,
        0,
        0,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]),
    );
    final invoice = Invoice(
      number: 1001,
      issuedAt: DateTime(2025, 3, 21, 10, 30),
      customer: 'مریم رضایی',
      discount: 10000,
      lines: const [
        InvoiceLine(
          code: '1',
          name: 'شیر کم‌چرب ۱ لیتری',
          unitPrice: 48000,
          quantity: 2,
        ),
        InvoiceLine(
          code: '2',
          name: 'چای سیاه ۴۵۰ گرمی',
          unitPrice: 320000,
          quantity: 1,
        ),
      ],
    );

    final bytes = await service.build(invoice);

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final out = Platform.environment['INVOICE_PDF_OUT'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });
}
