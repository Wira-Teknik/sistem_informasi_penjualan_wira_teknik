import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart'; // Pastikan BillingOrderModel dan PaymentModel terimport dari sini
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/bukti_pembayaran_dialog_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_invoice_widget.dart';

class OrderPaymentCard extends ConsumerStatefulWidget {
  final BillingOrderModel billingOrder;
  final String Function(int) formatRupiah;
  final Color Function(String) paymentStatusColor;
  final String Function(String) paymentStatusLabel;

  const OrderPaymentCard({
    super.key,
    required this.billingOrder,
    required this.formatRupiah,
    required this.paymentStatusColor,
    required this.paymentStatusLabel,
  });

  @override
  ConsumerState<OrderPaymentCard> createState() => _OrderPaymentCardState();
}

class _OrderPaymentCardState extends ConsumerState<OrderPaymentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
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
          // Header — PO, badge status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.billingOrder.poNo,
                      style: boldTextStyle.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CustomBadge(
                label: widget.paymentStatusLabel(
                  widget.billingOrder.paymentStatus,
                ),
                badgeColor: widget.paymentStatusColor(
                  widget.billingOrder.paymentStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tanggal & total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TANGGAL BELI",
                    style: boldTextStyle.copyWith(
                      fontSize: 10,
                      color: semiSecondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(widget.billingOrder.orderDate, style: mediumTextStyle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "JUMLAH TOTAL",
                    style: boldTextStyle.copyWith(fontSize: 10),
                  ),
                  Text(
                    widget.formatRupiah(widget.billingOrder.totalAmountToPay),
                    style: boldTextStyle.copyWith(
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (widget.billingOrder.payments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),
            const SizedBox(height: 8),

            Text(
              "Histori Pembayaran",
              style: semiBoldTextStyle.copyWith(
                fontSize: 12,
                color: semiSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),

            ...widget.billingOrder.payments.map(
              (payment) => ItemInvoiceWidget(
                paymentId: payment.paymentId,
                paymentTotal: payment.allocatedAmount,
                paymentDate: payment.paymentDate,
                formatRupiah: widget.formatRupiah,
                paymentStatus: widget.billingOrder.paymentStatus,
              ),
            ),
          ],

          const SizedBox(height: 10),
          Divider(color: secondaryColor),
          const SizedBox(height: 10),

          // Sisa pembayaran
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "JUMLAH SISA",
                  style: boldTextStyle.copyWith(fontSize: 10),
                ),
                Text(
                  widget.billingOrder.remainingBalance > 0
                      ? widget.formatRupiah(
                          widget.billingOrder.remainingBalance,
                        )
                      : "Lunas",
                  style: boldTextStyle.copyWith(
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tombol lihat bukti
          if (widget.billingOrder.payments.isNotEmpty)
            SizedBox(
              width: 149,
              child: CustomFilledbutton(
                title: "Lihat Bukti Pembayaran",
                buttonTitleSize: 10,
                buttonRadius: 100,
                buttonColor: secondaryColor,
                onPressed: () => _showBuktiPembayaranDialog(
                  context,
                  widget.billingOrder.payments,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBuktiPembayaranDialog(
    BuildContext context,
    List<PaymentModel> payments,
  ) {
    showDialog(
      context: context,
      builder: (context) => BuktiPembayaranDialogWidget(payments: payments),
    );
  }
}
