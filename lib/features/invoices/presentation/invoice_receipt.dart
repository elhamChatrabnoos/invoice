import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_logo.dart';
import '../domain/invoice.dart';

/// On-screen invoice styled like a paper receipt with a torn bottom edge.
class InvoiceReceipt extends StatelessWidget {
  const InvoiceReceipt({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .10),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipPath(
        clipper: const _TornEdgeClipper(),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReceiptHeader(invoice: invoice),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoRow(invoice: invoice),
                    const SizedBox(height: 20),
                    const _TableHeader(),
                    for (var i = 0; i < invoice.lines.length; i++)
                      _LineRow(index: i, line: invoice.lines[i]),
                    const SizedBox(height: 16),
                    const _DashedDivider(),
                    const SizedBox(height: 16),
                    _TotalRow(
                      'جمع کالاها (${fa(invoice.itemCount)} عدد)',
                      toman(invoice.subtotal),
                    ),
                    if (invoice.discount > 0)
                      _TotalRow(
                        'تخفیف',
                        toman(invoice.discount),
                        color: AppColors.danger,
                      ),
                    const SizedBox(height: 12),
                    _GrandTotal(total: invoice.total),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'از خرید شما سپاسگزاریم',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptHeader extends StatelessWidget {
  const _ReceiptHeader({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Row(
        children: [
          const AppLogo(size: 54, shadow: false),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('فاکتور فروش', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  'شماره',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  fa(invoice.number),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    Widget cell(IconData icon, String label, String value) => Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          cell(
            Icons.calendar_month_rounded,
            'تاریخ',
            jalaliDate(invoice.issuedAt),
          ),
          cell(Icons.schedule_rounded, 'ساعت', clock(invoice.issuedAt)),
          cell(
            Icons.person_rounded,
            'خریدار',
            invoice.customer.isEmpty ? 'مشتری عمومی' : invoice.customer,
          ),
        ],
      ),
    );
  }
}

const _columnFlex = [5, 2, 3];

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 12,
      color: AppColors.muted,
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: _columnFlex[0],
            child: const Text('کالا', style: style),
          ),
          Expanded(
            flex: _columnFlex[1],
            child: const Text(
              'تعداد',
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: _columnFlex[2],
            child: const Text('مبلغ', style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.index, required this.line});

  final int index;
  final InvoiceLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEEF7))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _columnFlex[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fa(index + 1)}. ${line.name}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${money(line.unitPrice)} × ${fa(line.quantity)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _columnFlex[1],
            child: Text(
              fa(line.quantity),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: _columnFlex[2],
            child: Text(
              money(line.total),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    ),
  );
}

class _GrandTotal extends StatelessWidget {
  const _GrandTotal({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
    ),
    child: Row(
      children: [
        const Text(
          'مبلغ قابل پرداخت',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          toman(total),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      const dash = 6.0, gap = 5.0;
      final count = (constraints.maxWidth / (dash + gap)).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          count,
          (_) => const SizedBox(
            width: dash,
            height: 1.5,
            child: ColoredBox(color: Color(0xFFD6D3EA)),
          ),
        ),
      );
    },
  );
}

class _TornEdgeClipper extends CustomClipper<Path> {
  const _TornEdgeClipper();

  @override
  Path getClip(Size size) {
    const tooth = 14.0, depth = 8.0, radius = 24.0;
    final path = Path()
      ..moveTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height);
    final teeth = (size.width / tooth).ceil();
    final step = size.width / teeth;
    for (var i = 0; i < teeth; i++) {
      final x = size.width - i * step;
      path
        ..lineTo(x - step / 2, size.height - depth)
        ..lineTo(x - step, size.height);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_TornEdgeClipper oldClipper) => false;
}
