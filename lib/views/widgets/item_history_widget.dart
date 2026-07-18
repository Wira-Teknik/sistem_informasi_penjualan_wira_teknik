import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/history_transaction_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';

class ItemHistoryWidget extends StatelessWidget {
  final HistoryTransactionModel item;
  final String Function(int) formatRupiah;
  final Color Function(String) paymentStatusColor;

  const ItemHistoryWidget({
    super.key,
    required this.item,
    required this.formatRupiah,
    required this.paymentStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header — transaction no, po no, badge status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "${item.transactionNo} #${item.poNo}",
                        style: semiBoldTextStyle.copyWith(
                          fontSize: 12,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.customerName.toUpperCase(),
                      style: boldTextStyle.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CustomBadge(
                label: _paymentStatusLabel(item.paymentStatus.toLowerCase()),
                badgeColor: paymentStatusColor(item.paymentStatus),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Footer — admin, tanggal, total
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.adminName,
                      style: mediumTextStyle.copyWith(fontSize: 12),
                    ),
                    Text(
                      item.createdAt,
                      style: regularTextStyle.copyWith(
                        fontSize: 12,
                        color: semiSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
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
                    formatRupiah(item.totalAmount),
                    style: boldTextStyle.copyWith(
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _paymentStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'paid' => 'Lunas',
      'partial' => 'Dibayar Sebagian',
      'unpaid' => 'Belum Bayar',
      _ => status,
    };
  }
}
