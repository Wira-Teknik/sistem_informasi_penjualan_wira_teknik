import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/detail_payment_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: "Pembayaran"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            CustomTextfield(
              controller: _searchController,
              hintText: "Cari nama perusahaan",
              prefixIcon: Icons.search,
              onChanged: (value) =>
                  ref.read(paymentViewModelProvider.notifier).search(value),
            ),
            const SizedBox(height: 22),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PaymentState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (state.errorMessage != null) {
      return Center(
        child: CustomRefreshErrorWidget(
          message: state.errorMessage!,
          onPressed: () =>
              ref.read(paymentViewModelProvider.notifier).loadBillings(),
        ),
      );
    }

    if (state.filteredBillings.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data tagihan',
          style: regularTextStyle.copyWith(color: semiSecondaryColor),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () => ref.read(paymentViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.filteredBillings.length,
        itemBuilder: (context, index) {
          return _CustomerBillingCard(
            billing: state.filteredBillings[index],
            formatRupiah: formatRupiah,
            formatDate: formatDate,
            onOrderTap: (order) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPaymentScreen(
                    billing: state.filteredBillings[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CustomerBillingCard extends StatefulWidget {
  final CustomerBillingModel billing;
  final String Function(int) formatRupiah;
  final String Function(String) formatDate;
  final ValueChanged<OrderModel> onOrderTap;

  const _CustomerBillingCard({
    required this.billing,
    required this.formatRupiah,
    required this.formatDate,
    required this.onOrderTap,
  });

  @override
  State<_CustomerBillingCard> createState() => _CustomerBillingCardState();
}

class _CustomerBillingCardState extends State<_CustomerBillingCard> {
  // Expand/collapse list order per customer
  bool _isExpanded = true;

  Color _paymentStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'partial' => orangeColor,
      'unpaid' => redColor,
      _ => semiSecondaryColor,
    };
  }

  String _paymentStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'partial' => 'Partial',
      'unpaid' => 'Unpaid',
      _ => status,
    };
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
                      const SizedBox(height: 4),
                      Text(
                        "${widget.billing.orders.length}",
                        style: boldTextStyle,
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
                      widget.formatRupiah(widget.billing.totalTagihan),
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
                        size: 20,
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
            ...widget.billing.orders.map(
              (order) => _OrderItem(
                order: order,
                formatRupiah: widget.formatRupiah,
                formatDate: widget.formatDate,
                paymentStatusColor: _paymentStatusColor,
                paymentStatusLabel: _paymentStatusLabel,
                onTap: () => widget.onOrderTap(order),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatRupiah;
  final String Function(String) formatDate;
  final Color Function(String) paymentStatusColor;
  final String Function(String) paymentStatusLabel;
  final VoidCallback onTap;

  const _OrderItem({
    required this.order,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.transactionNo,
                    style: boldTextStyle.copyWith(fontSize: 12),
                  ),
                  Text(
                    formatDate(order.orderDate),
                    style: mediumTextStyle.copyWith(
                      fontSize: 10,
                      color: semiSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Status pembayaran
            CustomBadge(
              label: paymentStatusLabel(order.paymentStatus),
              badgeColor: paymentStatusColor(order.paymentStatus),
            ),
            const SizedBox(width: 16),

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
                  formatRupiah(order.remainingBalance),
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
