import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/format.dart';
import '../../../core/widgets/app_logo.dart';
import '../domain/invoice.dart';

final invoicePdfServiceProvider = Provider<InvoicePdfService>(
  (ref) => InvoicePdfService(),
);

/// Renders invoices as RTL Persian PDFs and hands them to the OS for
/// printing or sharing.
class InvoicePdfService {
  InvoicePdfService({AssetBundle? bundle, Future<Uint8List> Function()? logo})
    : _bundle = bundle ?? rootBundle,
      _logo = logo ?? (() => renderLogoPng(size: 256));

  final AssetBundle _bundle;
  final Future<Uint8List> Function() _logo;

  // Loaded once and reused for every document.
  late final Future<_Assets> _assets = _loadAssets();

  Future<_Assets> _loadAssets() async {
    final results = await Future.wait([
      _bundle.load('assets/fonts/Vazirmatn-Regular.ttf'),
      _bundle.load('assets/fonts/Vazirmatn-Bold.ttf'),
      _bundle.load('assets/fonts/Vazirmatn-Black.ttf'),
    ]);
    return _Assets(
      regular: pw.Font.ttf(results[0]),
      bold: pw.Font.ttf(results[1]),
      black: pw.Font.ttf(results[2]),
      logo: pw.MemoryImage(await _logo()),
    );
  }

  Future<void> printInvoice(Invoice invoice) => Printing.layoutPdf(
    name: _fileName(invoice),
    onLayout: (format) => build(invoice, format: format),
  );

  Future<void> shareInvoice(Invoice invoice) async => Printing.sharePdf(
    bytes: await build(invoice),
    filename: '${_fileName(invoice)}.pdf',
  );

  String _fileName(Invoice invoice) => 'invoice-${invoice.number}';

  Future<Uint8List> build(
    Invoice invoice, {
    PdfPageFormat format = PdfPageFormat.a5,
  }) async {
    final a = await _assets;
    final doc = pw.Document(
      title: 'فاکتور ${invoice.number}',
      author: appName,
      theme: pw.ThemeData.withFont(base: a.regular, bold: a.bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(28),
        textDirection: pw.TextDirection.rtl,
        header: (_) => _header(invoice, a),
        footer: (context) => _footer(invoice, context),
        build: (_) => [
          if (invoice.customer.isNotEmpty) _customer(invoice),
          pw.SizedBox(height: 14),
          _table(invoice),
          pw.SizedBox(height: 14),
          _totals(invoice, a),
        ],
      ),
    );
    return doc.save();
  }

  static const _primary = PdfColor.fromInt(0xFF5B4BDB);
  static const _primarySoft = PdfColor.fromInt(0xFFEFEDFC);
  static const _teal = PdfColor.fromInt(0xFF1FBFA3);
  static const _ink = PdfColor.fromInt(0xFF1E1B3A);
  static const _muted = PdfColor.fromInt(0xFF7A7799);
  static const _line = PdfColor.fromInt(0xFFE6E4F2);

  pw.Widget _header(Invoice invoice, _Assets a) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 18),
    padding: const pw.EdgeInsets.only(bottom: 14),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _teal, width: 2)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(a.logo, width: 46, height: 46),
        pw.SizedBox(width: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _pdfText(appName),
              style: pw.TextStyle(font: a.black, fontSize: 20, color: _primary),
            ),
            pw.Text(
              appTagline,
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'فاکتور فروش',
              style: pw.TextStyle(font: a.black, fontSize: 16, color: _ink),
            ),
            pw.SizedBox(height: 2),
            _meta('شماره', fa(invoice.number)),
            _meta('تاریخ', jalaliDate(invoice.issuedAt)),
            _meta('ساعت', clock(invoice.issuedAt)),
          ],
        ),
      ],
    ),
  );

  pw.Widget _meta(String label, String value) => pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Text(
        '$label: ',
        style: const pw.TextStyle(fontSize: 9, color: _muted),
      ),
      pw.Text(
        value,
        style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    ],
  );

  pw.Widget _customer(Invoice invoice) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: pw.BoxDecoration(
      color: _primarySoft,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      children: [
        pw.Text(
          'خریدار: ',
          style: const pw.TextStyle(fontSize: 10, color: _muted),
        ),
        pw.Text(
          _pdfText(invoice.customer),
          style: const pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  // Column flex: #, name, qty, unit price, total.
  static const _flex = [2, 7, 2, 4, 4];

  pw.Widget _row(
    List<String> cells, {
    bool header = false,
    bool shaded = false,
  }) {
    final style = header
        ? const pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          )
        : const pw.TextStyle(fontSize: 9.5, color: _ink);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: pw.BoxDecoration(
        color: header ? _primary : (shaded ? _primarySoft : null),
        borderRadius: header ? pw.BorderRadius.circular(6) : null,
        border: header
            ? null
            : const pw.Border(bottom: pw.BorderSide(color: _line, width: .6)),
      ),
      child: pw.Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            pw.Expanded(
              flex: _flex[i],
              child: pw.Text(
                _pdfText(cells[i]),
                style: style,
                textAlign: i == 1 ? pw.TextAlign.right : pw.TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _table(Invoice invoice) => pw.Column(
    children: [
      _row(['ردیف', 'شرح کالا', 'تعداد', 'قیمت واحد', 'مبلغ کل'], header: true),
      for (var i = 0; i < invoice.lines.length; i++)
        _row([
          fa(i + 1),
          invoice.lines[i].name,
          fa(invoice.lines[i].quantity),
          money(invoice.lines[i].unitPrice),
          money(invoice.lines[i].total),
        ], shaded: i.isOdd),
    ],
  );

  pw.Widget _totals(Invoice invoice, _Assets a) => pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.BarcodeWidget(
        barcode: pw.Barcode.code128(),
        data: 'INV-${invoice.number}',
        width: 110,
        height: 44,
        textPadding: 3,
        textStyle: pw.TextStyle(font: a.regular, fontSize: 7, color: _muted),
      ),
      pw.Spacer(),
      pw.Container(
        width: 190,
        child: pw.Column(
          children: [
            _sum(
              'جمع کالاها (${fa(invoice.itemCount)} عدد)',
              toman(invoice.subtotal),
            ),
            if (invoice.discount > 0) _sum('تخفیف', toman(invoice.discount)),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(
                color: _primary,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    'مبلغ قابل پرداخت',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    toman(invoice.total),
                    style: pw.TextStyle(
                      font: a.black,
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  pw.Widget _sum(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    child: pw.Row(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
        pw.Spacer(),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  pw.Widget _footer(Invoice invoice, pw.Context context) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 12),
    padding: const pw.EdgeInsets.only(top: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _line)),
    ),
    child: pw.Row(
      children: [
        pw.Text(
          'از خرید شما سپاسگزاریم',
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
        pw.Spacer(),
        pw.Text(
          fa('صفحه ${context.pageNumber} از ${context.pagesCount}'),
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
      ],
    ),
  );
}

/// The PDF shaper draws the zero-width non-joiner (نیم‌فاصله) as a glyph;
/// a plain space gives the same letter forms without the artefact.
String _pdfText(String text) => text.replaceAll('\u200c', ' ');

class _Assets {
  const _Assets({
    required this.regular,
    required this.bold,
    required this.black,
    required this.logo,
  });

  final pw.Font regular;
  final pw.Font bold;
  final pw.Font black;
  final pw.MemoryImage logo;
}
