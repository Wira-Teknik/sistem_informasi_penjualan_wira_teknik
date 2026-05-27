import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';

class MenungguPembayaranWidget extends StatefulWidget {
  final CustomerBillingModel billing;
  final ValueChanged<List<OrderModel>> onOrdersChanged;

  const MenungguPembayaranWidget({
    super.key,
    required this.billing,
    required this.onOrdersChanged,
  });

  @override
  State<MenungguPembayaranWidget> createState() =>
      _MenungguPembayaranWidgetState();
}

class _MenungguPembayaranWidgetState extends State<MenungguPembayaranWidget> {
  late Map<String, bool> _selected;

  // Hanya tampilkan order yang belum lunas
  List<OrderModel> get _unpaidOrders => widget.billing.orders
      .where(
        (o) =>
            o.paymentStatus.toLowerCase() != 'paid' &&
            o.shipments.isNotEmpty &&
            o.shipments.any(
              (s) =>
                  s.invoice != null &&
                  s.invoice!.paymentStatus.toLowerCase() != 'paid',
            ),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    // Default semua dipilih
    _selected = {for (final o in _unpaidOrders) o.id: true};
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  void _notifyParent() {
    final selectedOrders = _unpaidOrders
        .where((o) => _selected[o.id] == true)
        .toList();
    widget.onOrdersChanged(selectedOrders);
  }

  bool get _isAllSelected => _selected.values.every((v) => v == true);

  void _toggleAll() {
    setState(() {
      final selectAll = !_isAllSelected;
      for (final key in _selected.keys) {
        _selected[key] = selectAll;
      }
    });
    _notifyParent();
  }

  void _toggleItem(String id, bool value) {
    setState(() => _selected[id] = value);
    _notifyParent();
  }

  Color _paymentStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'unpaid' => redColor,
      'partial' => orangeColor,
      _ => semiSecondaryColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menunggu Pembayaran', style: semiBoldTextStyle),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleAll,
                      child: Text(
                        'PILIH SEMUA',
                        style: semiBoldTextStyle.copyWith(
                          fontSize: 10,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleAll,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _isAllSelected
                              ? primaryColor
                              : semiSecondaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: semiSecondaryColor.withValues(alpha: 0.1)),

          // Kosong
          if (_unpaidOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Semua pesanan sudah lunas',
                  style: regularTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ),
            ),

          // List order
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _unpaidOrders.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: semiSecondaryColor.withValues(alpha: 0.1),
            ),
            itemBuilder: (context, index) {
              final order = _unpaidOrders[index];
              final isSelected = _selected[order.id] ?? false;

              return GestureDetector(
                onTap: () => _toggleItem(order.id, !isSelected),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : semiSecondaryColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Info order
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.transactionNo,
                              style: boldTextStyle.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              order.orderDate,
                              style: regularTextStyle.copyWith(
                                fontSize: 11,
                                color: semiSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status & sisa tagihan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatRupiah(order.remainingBalance),
                            style: boldTextStyle.copyWith(
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 28,
                            child: CustomBadge(
                              label: order.paymentStatus,
                              badgeColor: _paymentStatusColor(
                                order.paymentStatus,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
