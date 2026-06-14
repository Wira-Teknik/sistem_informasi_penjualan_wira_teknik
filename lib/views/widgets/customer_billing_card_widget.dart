import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class CustomerBillingCardWidget extends StatefulWidget {
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

  @override
  State<CustomerBillingCardWidget> createState() =>
      _CustomerBillingCardWidgetState();
}

class _CustomerBillingCardWidgetState extends State<CustomerBillingCardWidget> {
  bool _isExpanded = false;

  String _searchQuery = '';

  List<BillingOrderModel> get _filteredOrders {
    if (_searchQuery.isEmpty) {
      return widget.billing.orders;
    }
    return widget.billing.orders.where((order) {
      return order.transactionNo.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Header customer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.billing.customerName.toUpperCase(),
                        style: boldTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Pesanan yang harus dibayar",
                        style: mediumTextStyle.copyWith(
                          fontSize: 10,
                          color: semiSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${widget.billing.orders.where((o) => o.paymentStatus.toUpperCase() != "PAID").length} Pesanan",
                        style: boldTextStyle.copyWith(fontSize: 16),
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
                      widget.billing.totalTagihan != 0
                          ? widget.formatRupiah(widget.billing.totalTagihan)
                          : 'Lunas',
                      style: boldTextStyle.copyWith(color: primaryColor),
                    ),
                    const SizedBox(height: 4),
                    // Toggle expand
                    GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List order per customer
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: semiSecondaryColor.withValues(alpha: 0.1),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: CustomTextfield(
                hintText: 'Cari nomor transaksi..',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            if (_filteredOrders.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Nomor transaksi tidak ditemukan',
                  style: regularTextStyle.copyWith(
                    color: semiSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ] else ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 350),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final billingOrder = _filteredOrders[index];
                    return _OrderItem(
                      billingOrder: billingOrder,
                      formatRupiah: widget.formatRupiah,
                      formatDate: widget.formatDate,
                      paymentStatusColor: _paymentStatusColor,
                      paymentStatusLabel: _paymentStatusLabel,
                      onTap: () => widget.onOrderTap(billingOrder),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _paymentStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => greenColor,
      'partial' => orangeColor,
      'unpaid' => redColor,
      _ => semiSecondaryColor,
    };
  }

  String _paymentStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'paid' => 'Paid',
      'partial' => 'Partial',
      'unpaid' => 'Unpaid',
      _ => status,
    };
  }
}

class _OrderItem extends StatelessWidget {
  final BillingOrderModel billingOrder;
  final String Function(int) formatRupiah;
  final String Function(String) formatDate;
  final Color Function(String) paymentStatusColor;
  final String Function(String) paymentStatusLabel;
  final VoidCallback onTap;

  const _OrderItem({
    required this.billingOrder,
    required this.formatRupiah,
    required this.formatDate,
    required this.paymentStatusColor,
    required this.paymentStatusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // No transaksi & tanggal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  billingOrder.transactionNo,
                  style: boldTextStyle.copyWith(fontSize: 12),
                ),
                Text(
                  formatDate(billingOrder.orderDate),
                  style: mediumTextStyle.copyWith(
                    fontSize: 10,
                    color: semiSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 30),
            // Status pembayaran
            CustomBadge(
              label: paymentStatusLabel(billingOrder.paymentStatus),
              badgeColor: paymentStatusColor(billingOrder.paymentStatus),
            ),
            const Spacer(),
            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "TOTAL",
                  style: boldTextStyle.copyWith(
                    fontSize: 9,
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  formatRupiah(billingOrder.totalAmountToPay),
                  style: boldTextStyle.copyWith(
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
