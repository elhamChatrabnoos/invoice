import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../domain/invoice.dart';

class InvoiceTile extends StatelessWidget {
  const InvoiceTile({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => context.push(AppRoutes.invoice(invoice.number)),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.customer.isEmpty
                      ? 'فاکتور ${fa(invoice.number)}'
                      : '${fa(invoice.number)} – ${invoice.customer}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${jalaliDate(invoice.issuedAt)}، ساعت ${clock(invoice.issuedAt)}، ${fa(invoice.itemCount)} کالا',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            toman(invoice.total),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
