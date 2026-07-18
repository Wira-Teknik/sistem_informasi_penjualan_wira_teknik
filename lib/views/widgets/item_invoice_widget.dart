import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/edit_payment_dialog_widget.dart';

class ItemInvoiceWidget extends StatefulWidget {
  final String paymentId;
  final String orderId; // Wajib untuk API
  final String invoiceNo;
  final int paymentTotal;
  final String paymentDate;
  final String Function(int) formatRupiah;
  final String paymentStatus;

  // Kirim data riwayat pembayaran untuk invoice ini
  final List<PaymentModel> relatedPayments;
  final VoidCallback onRefreshTapped;

  const ItemInvoiceWidget({
    super.key,
    required this.formatRupiah,
    required this.paymentStatus,
    required this.paymentTotal,
    required this.paymentDate,
    required this.paymentId,
    required this.orderId,
    required this.invoiceNo,
    required this.relatedPayments,
    required this.onRefreshTapped,
  });

  @override
  State<ItemInvoiceWidget> createState() => _ItemInvoiceWidgetState();
}

class _ItemInvoiceWidgetState extends State<ItemInvoiceWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (widget.paymentStatus.toUpperCase() == "PAID")
              ? const SizedBox()
              : SizedBox(
                  width: 18,
                  height: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showEditPaymentDialog(
                      context,
                      widget.paymentId,
                      widget.paymentTotal.toDouble(),
                    ),
                    icon: const ImageIcon(
                      AssetImage("assets/icons/edit_pengiriman_icon.png"),
                      size: 18,
                      color: secondaryColor,
                    ),
                  ),
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.invoiceNo,
                  style: boldTextStyle.copyWith(
                    fontSize: 10,
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(widget.paymentDate, style: mediumTextStyle),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.formatRupiah(widget.paymentTotal),
                style: boldTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditPaymentDialog(
    BuildContext context,
    String paymentId,
    double currentTotal,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditPaymentDialogWidget(
        paymentId: paymentId,
        orderId: widget.orderId,
        invoiceNo: widget.invoiceNo,
        relatedPayments: widget.relatedPayments,
        currentTotal: currentTotal,
        onSuccess: widget.onRefreshTapped,
      ),
    );
  }
}
