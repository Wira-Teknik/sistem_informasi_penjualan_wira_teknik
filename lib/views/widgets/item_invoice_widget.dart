import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/edit_payment_dialog_widget.dart';

class ItemInvoiceWidget extends StatefulWidget {
  final String paymentId;
  final int paymentTotal;
  final String paymentDate;
  final String Function(int) formatRupiah;
  final String paymentStatus;

  const ItemInvoiceWidget({
    super.key,
    required this.formatRupiah,
    required this.paymentStatus,
    required this.paymentTotal,
    required this.paymentDate,
    required this.paymentId,
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
              ? SizedBox()
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
                    icon: ImageIcon(
                      const AssetImage("assets/icons/edit_pengiriman_icon.png"),
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
                  "TANGGAL BAYAR",
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
        currentTotal: currentTotal,
        onSuccess: () {
          // Refresh data setelah berhasil edit
          setState(() {});
        },
      ),
    );
  }
}
