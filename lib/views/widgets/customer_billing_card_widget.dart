import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/detail_payment_screen.dart';

class CustomerBillingCardWidget extends StatelessWidget {
  final CustomerBillingModel billing;
  final String Function(int) formatRupiah;
  final String Function(String) formatDate;
  final ValueChanged<BillingOrderModel> onOrderTap;

  const CustomerBillingCardWidget({
    super.key,
    required this.billing,
    required this.formatRupiah,
    required this.formatDate,
    required this.onOrderTap,
  });

  int get _totalOrders {
    return billing.totalPaid + billing.totalUnpaid + billing.totalPartial;
  }

  bool get _isLunas => billing.totalTagihan == 0;

  String get _initials {
    final words = billing.customerName.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPaymentScreen(customerName: billing.customerName),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 1, right: 1, top: 1, bottom: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar inisial
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isLunas
                          ? greenColor.withValues(alpha: 0.1)
                          : primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: boldTextStyle.copyWith(
                          fontSize: 15,
                          color: _isLunas ? greenColor : primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          billing.customerName.toUpperCase(),
                          style: boldTextStyle.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 13,
                              color: semiSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_totalOrders Pesanan',
                              style: regularTextStyle.copyWith(
                                fontSize: 12,
                                color: semiSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _isLunas
                      ? greenColor.withValues(alpha: 0.06)
                      : primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLunas ? 'STATUS' : 'TOTAL TAGIHAN',
                      style: boldTextStyle.copyWith(
                        fontSize: 11,
                        color: _isLunas ? greenColor : primaryColor,
                      ),
                    ),
                    if (_isLunas)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: greenColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lunas',
                            style: boldTextStyle.copyWith(
                              fontSize: 14,
                              color: greenColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        formatRupiah(billing.totalTagihan),
                        style: boldTextStyle.copyWith(
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Divider(
              height: 1,
              color: semiSecondaryColor.withValues(alpha: 0.08),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatusChip(
                      label: 'Lunas',
                      count: billing.totalPaid,
                      color: greenColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusChip(
                      label: 'Sebagian',
                      count: billing.totalPartial,
                      color: yellowColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusChip(
                      label: 'Belum Bayar',
                      count: billing.totalUnpaid,
                      color: redColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: boldTextStyle.copyWith(fontSize: 14, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: boldTextStyle.copyWith(fontSize: 10, color: color),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
