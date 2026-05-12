import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/order_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/edit_order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';

class DetailOrderScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const DetailOrderScreen({super.key, required this.order});

  @override
  ConsumerState<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends ConsumerState<DetailOrderScreen> {
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  // Refresh dari list order di viewmodel
  Future<void> _onRefresh() async {
    await ref.read(orderViewModelProvider.notifier).refresh();
    final updated = ref
        .read(orderViewModelProvider)
        .orders
        .firstWhere((o) => o.id == _order.id, orElse: () => _order);
    setState(() => _order = updated);
  }

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
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // Warna badge order status
  Color _orderStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => primaryColor,
      'partial' => yellowColor,
      'shipped' => yellowColor,
      'completed' => greenColor,
      _ => semiSecondaryColor,
    };
  }

  // Label badge order status
  String _orderStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'pending' => 'Pending',
      'partial' => 'Partial',
      'shipped' => 'Shipped',
      'completed' => 'Completed',
      _ => status,
    };
  }

  // Warna badge shipping status
  Color _shippingStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'dikirim' => yellowColor,
      'diterima' => greenColor,
      _ => semiSecondaryColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Detail Pesanan",
        actions: [
          IconButton(
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditOrderScreen(order: _order),
                ),
              );

              // Jika ada update, ambil data terbaru dari state
              if (updated == true) {
                final latest = ref
                    .read(orderViewModelProvider)
                    .orders
                    .firstWhere((o) => o.id == _order.id, orElse: () => _order);

                setState(() => _order = latest);
              }
            },
            icon: ImageIcon(
              const AssetImage("assets/icons/edit_pesanan.png"),
              color: secondaryColor,
              size: 20,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi pesanan
              _buildOrderInfoCard(),
              const SizedBox(height: 20),

              // Informasi konsumen
              Text("INFORMASI KONSUMEN", style: boldTextStyle),
              const SizedBox(height: 12),
              _buildRecipientCard(),
              const SizedBox(height: 20),

              // Barang pesanan
              Text(
                "BARANG PESANAN (${_order.items.length})",
                style: boldTextStyle,
              ),
              const SizedBox(height: 12),
              _buildItemsCard(),
              const SizedBox(height: 20),

              // Status pembayaran
              Text("STATUS PEMBAYARAN", style: boldTextStyle),
              const SizedBox(height: 12),
              _buildPaymentCard(),
              const SizedBox(height: 20),

              // Pengiriman
              if (_order.shipments.isNotEmpty) ...[
                Text("PENGIRIMAN", style: boldTextStyle),
                const SizedBox(height: 12),
                ..._order.shipments.map(
                  (shipment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildShipmentCard(shipment),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Tombol buat pengiriman
              CustomFilledbutton(
                title: "Buat Pengiriman",
                iconButton: Icons.edit_note_rounded,
                buttonRadius: 12,
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AddDeliveryScreen(order: _order),
                  //   ),
                  // );
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // Card informasi pesanan
  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/icons/box_icon.png",
                    width: 18,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "No Transaksi",
                    style: semiBoldTextStyle.copyWith(
                      fontSize: 12,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _order.transactionNo,
                style: boldTextStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                "Updated: ${_formatDate(_order.updatedAt)}",
                style: regularTextStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          CustomBadge(
            label: _orderStatusLabel(_order.orderStatus),
            badgeColor: _orderStatusColor(_order.orderStatus),
          ),
        ],
      ),
    );
  }

  // Card informasi konsumen
  Widget _buildRecipientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/icons/company_icon.png",
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order.recipientName.toUpperCase(),
                      style: boldTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "No PO: ${_order.poNo}",
                      style: regularTextStyle.copyWith(
                        fontSize: 12,
                        color: semiSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            _order.recipientEmail,
            style: regularTextStyle.copyWith(color: semiSecondaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            _order.recipientPhone,
            style: regularTextStyle.copyWith(color: semiSecondaryColor),
          ),

          const SizedBox(height: 10),
          Divider(color: semiSecondaryColor.withValues(alpha: 0.2)),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/icons/location_icon.png",
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _order.recipientAddress,
                  style: regularTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card daftar barang
  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: _order.items.asMap().entries.map((entry) {
          final item = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName, style: semiBoldTextStyle),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatRupiah(item.unitPrice),
                    style: boldTextStyle.copyWith(color: primaryColor),
                  ),
                  const Spacer(),
                  Text(
                    "x ${item.orderQty}",
                    style: boldTextStyle.copyWith(color: primaryColor),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Divider(color: semiSecondaryColor.withValues(alpha: 0.2)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Card status pembayaran
  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Status Sekarang", style: semiBoldTextStyle),
              const Spacer(),
              // Status pembayaran belum ada di model order
              // sesuaikan saat endpoint payment tersedia
              CustomBadge(label: "Unpaid", badgeColor: redColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "JUMLAH TOTAL",
                style: boldTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
              const Spacer(),
              Text(
                _formatRupiah(_order.totalAmount),
                style: boldTextStyle.copyWith(color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card per shipment
  Widget _buildShipmentCard(ShipmentModel shipment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                height: 18,
                width: 18,
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    const AssetImage("assets/icons/edit_pengiriman_icon.png"),
                    size: 18,
                    color: secondaryColor,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
              CustomBadge(
                label: shipment.shippingStatus,
                badgeColor: _shippingStatusColor(shipment.shippingStatus),
              ),
              const Spacer(),
              Text(
                _formatDate(shipment.shippingDate),
                style: regularTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item pengiriman — match dengan item order by order_item_id
          ...shipment.items.map((shipItem) {
            final orderItem = _order.items.firstWhere(
              (o) => o.id == shipItem.orderItemId,
              orElse: () => OrderItemModel(
                id: '',
                orderId: '',
                productName: 'Produk tidak diketahui',
                orderQty: 0,
                remainingQty: 0,
                unitPrice: 0,
                ppn: 0,
                subtotal: 0,
                createdAt: '',
                updatedAt: '',
              ),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      orderItem.productName,
                      style: semiBoldTextStyle,
                    ),
                  ),
                  Text(
                    "x ${shipItem.shippingQty}",
                    style: semiBoldTextStyle.copyWith(color: primaryColor),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomFilledbutton(
                title: "Dokumen Pendukung",
                buttonColor: secondaryColor,
                buttonRadius: 20,
                buttonTitleSize: 10,
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              CustomFilledbutton(
                title: "Unggah Bukti",
                buttonRadius: 20,
                buttonTitleSize: 10,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dekorasi card yang konsisten
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: whiteColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: secondaryColor.withValues(alpha: 0.3), blurRadius: 1),
      ],
    );
  }
}
