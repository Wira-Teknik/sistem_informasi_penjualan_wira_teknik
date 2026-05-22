import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/add_payment_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_payment_section.dart';

class DetailPaymentScreen extends ConsumerStatefulWidget {
  final CustomerBillingModel billing;

  const DetailPaymentScreen({super.key, required this.billing});

  @override
  ConsumerState<DetailPaymentScreen> createState() =>
      _DetailPaymentScreenState();
}

class _DetailPaymentScreenState extends ConsumerState<DetailPaymentScreen> {
  int _activeFilter = 0;
  String _searchQuery = '';

  // Filter orders berdasarkan status & search
  List<OrderModel> get _filteredOrders {
    final filterStatus = _filterStatus[_activeFilter];
    var orders = widget.billing.orders;

    // Filter by status
    if (filterStatus != null) {
      orders = orders
          .where(
            (o) => o.paymentStatus.toLowerCase() == filterStatus.toLowerCase(),
          )
          .toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final keyword = _searchQuery.toLowerCase();
      orders = orders
          .where(
            (o) =>
                o.poNo.toLowerCase().contains(keyword) ||
                o.transactionNo.toLowerCase().contains(keyword),
          )
          .toList();
    }

    return orders;
  }

  static const _filterStatus = {0: null, 1: 'unpaid', 2: 'partial', 3: 'paid'};

  // Total remaining balance semua order customer ini
  int get _totalRemainingBalance =>
      widget.billing.orders.fold(0, (sum, o) => sum + o.remainingBalance);

  // Status keseluruhan customer
  String get _overallStatus {
    final orders = widget.billing.orders;
    if (orders.every((o) => o.paymentStatus.toLowerCase() == 'paid')) {
      return 'Lunas';
    } else if (orders.every((o) => o.paymentStatus.toLowerCase() == 'unpaid')) {
      return 'Belum Dibayar';
    }
    return 'Sebagian Dibayar';
  }

  Color get _overallStatusColor {
    return switch (_overallStatus) {
      'Lunas' => greenColor,
      'Belum Dibayar' => redColor,
      'Sebagian Dibayar' => orangeColor,
      _ => semiSecondaryColor,
    };
  }

  String _formatRupiah(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Detail Pembayaran'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // Informasi pembayaran customer
            Container(
              padding: const EdgeInsets.all(20),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.billing.customerName.toUpperCase(),
                              style: boldTextStyle.copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _overallStatus,
                              style: semiBoldTextStyle.copyWith(
                                fontSize: 12,
                                color: _overallStatusColor,
                              ),
                            ),
                            Text(
                              _formatRupiah(_totalRemainingBalance),
                              style: boldTextStyle.copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Image.asset("assets/icons/wallet_icon.png", width: 34),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol catat pembayaran
                  CustomFilledbutton(
                    title: "Catat Pembayaran",
                    iconButton: Icons.payments_outlined,
                    onPressed: () async {
                      final success = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPaymentScreen(
                            billing: widget.billing, // ← pass billing
                          ),
                        ),
                      );

                      // Refresh jika berhasil bayar
                      if (success == true) {
                        // reload data dari viewmodel
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pembayaran berhasil dicatat'),
                            ),
                          );
                          setState(() {}); // trigger rebuild untuk refresh
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Aktivitas Pesanan",
              style: boldTextStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Search
            CustomTextfield(
              hintText: "Cari nomor PO",
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 14),

            // Filter
            FilterPaymentSection(
              activeFilter: _activeFilter,
              onFilterChanged: (index) => setState(() => _activeFilter = index),
            ),
            const SizedBox(height: 14),

            // List order
            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data',
                        style: regularTextStyle.copyWith(
                          color: semiSecondaryColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 1, bottom: 24),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _OrderPaymentCard(
                          order: _filteredOrders[index],
                          formatRupiah: _formatRupiah,
                          paymentStatusColor: _paymentStatusColor,
                          paymentStatusLabel: _paymentStatusLabel,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPaymentCard extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatRupiah;
  final Color Function(String) paymentStatusColor;
  final String Function(String) paymentStatusLabel;

  const _OrderPaymentCard({
    required this.order,
    required this.formatRupiah,
    required this.paymentStatusColor,
    required this.paymentStatusLabel,
  });

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
          // Header — PO, nama, badge status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.poNo,
                      style: boldTextStyle.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      order.recipientName,
                      style: mediumTextStyle.copyWith(
                        fontSize: 14,
                        color: semiSecondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CustomBadge(
                label: paymentStatusLabel(order.paymentStatus),
                badgeColor: paymentStatusColor(order.paymentStatus),
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
                  Text(order.orderDate, style: mediumTextStyle),
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
                    formatRupiah(order.totalAmountToPay),
                    style: boldTextStyle.copyWith(
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Riwayat pembayaran dari shipments → invoices
          if (order.shipments.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),
            const SizedBox(height: 10),

            ...order.shipments
                .where((s) => s.invoice != null)
                .map(
                  (shipment) => _InvoiceItem(
                    shipment: shipment,
                    formatRupiah: formatRupiah,
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
                  formatRupiah(order.remainingBalance),
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
          SizedBox(
            width: 149,
            child: CustomFilledbutton(
              title: "Lihat Bukti Pembayaran",
              buttonTitleSize: 10,
              buttonRadius: 100,
              buttonColor: secondaryColor,
              onPressed: () {
                // navigasi ke bukti pembayaran
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceItem extends StatelessWidget {
  final ShipmentModel shipment;
  final String Function(int) formatRupiah;

  const _InvoiceItem({required this.shipment, required this.formatRupiah});

  @override
  Widget build(BuildContext context) {
    final invoice = shipment.invoice!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
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
                  "INV",
                  style: boldTextStyle.copyWith(
                    fontSize: 10,
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  invoice.invoiceNo,
                  style: mediumTextStyle.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  shipment.shippingDate,
                  style: mediumTextStyle.copyWith(
                    fontSize: 11,
                    color: semiSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatRupiah(invoice.totalAmount), style: boldTextStyle),
              // Badge status invoice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: invoice.paymentStatus.toLowerCase() == 'paid'
                      ? greenColor.withValues(alpha: 0.1)
                      : redColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  invoice.paymentStatus,
                  style: boldTextStyle.copyWith(
                    fontSize: 9,
                    color: invoice.paymentStatus.toLowerCase() == 'paid'
                        ? greenColor
                        : redColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
