import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';

class ItemPesananWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const ItemPesananWidget({super.key, required this.order, this.onTap});

  // Format rupiah
  String _formatRupiah(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // Format tanggal
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // Warna badge sesuai status
  Color _badgeColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => primaryColor,
      'partial' => yellowColor,
      'shipped' => yellowColor,
      'completed' => greenColor,
      // 'dibatal' => Colors.red,
      _ => semiSecondaryColor,
    };
  }

  // Label badge
  String _badgeLabel(String status) {
    return switch (status.toLowerCase()) {
      'pending' => 'Pending',
      'partial' => 'Partial',
      'shipped' => 'Shipped',
      'completed' => 'Completed',
      // 'dibatal' => 'Dibatalkan',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 1, right: 1, top: 1, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: semiSecondaryColor.withValues(alpha: 0.5),
              blurRadius: 0.5,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.poNo,
                        style: boldTextStyle.copyWith(fontSize: 16),
                      ),
                      Text(
                        order.recipientName.toUpperCase(),
                        style: mediumTextStyle.copyWith(
                          color: semiSecondaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CustomBadge(
                  label: _badgeLabel(order.orderStatus),
                  badgeColor: _badgeColor(order.orderStatus),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tanggal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TANGGAL",
                      style: boldTextStyle.copyWith(
                        fontSize: 10,
                        color: semiSecondaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(_formatDate(order.orderDate), style: mediumTextStyle),
                  ],
                ),

                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "JUMLAH TOTAL",
                      style: boldTextStyle.copyWith(
                        fontSize: 10,
                        color: semiSecondaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      _formatRupiah(order.totalAmountToPay.toDouble()),
                      style: boldTextStyle.copyWith(
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
