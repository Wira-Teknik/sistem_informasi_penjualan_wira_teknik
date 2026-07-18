import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/shipment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/shipment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class EditShipmentDialogWidget extends ConsumerStatefulWidget {
  final ShipmentModel shipment;
  final List<OrderItemModel> orderItems;
  final VoidCallback onSuccess;

  const EditShipmentDialogWidget({
    super.key,
    required this.shipment,
    required this.orderItems,
    required this.onSuccess,
  });

  @override
  ConsumerState<EditShipmentDialogWidget> createState() =>
      _EditShipmentDialogWidgetState();
}

class _EditShipmentDialogWidgetState
    extends ConsumerState<EditShipmentDialogWidget> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final item in widget.shipment.items)
        item.orderItemId: TextEditingController(
          text: item.shippingQty.toString(),
        ),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // Cari nama produk berdasarkan orderItemId
  String _getProductName(String orderItemId) {
    final orderItem = widget.orderItems.firstWhere(
      (o) => o.id == orderItemId,
      orElse: () => OrderItemModel(
        id: '',
        productName: 'Produk tidak diketahui',
        orderQty: 0,
        remainingQty: 0,
        unitPrice: 0,
        ppn: 0,
        subtotal: 0,
      ),
    );
    return orderItem.productName;
  }

  // Max qty = remainingQty + shippingQty saat ini
  int _getMaxQty(String orderItemId) {
    final orderItem = widget.orderItems.firstWhere(
      (o) => o.id == orderItemId,
      orElse: () => OrderItemModel(
        id: '',
        productName: '',
        orderQty: 0,
        remainingQty: 0,
        unitPrice: 0,
        ppn: 0,
        subtotal: 0,
      ),
    );
    final shipItem = widget.shipment.items.firstWhere(
      (s) => s.orderItemId == orderItemId,
    );
    return orderItem.remainingQty + shipItem.shippingQty;
  }

  Future<void> _onSimpan() async {
    // Validasi semua qty
    for (final entry in _controllers.entries) {
      final qty = int.tryParse(entry.value.text.trim());
      final max = _getMaxQty(entry.key);

      if (qty == null || qty <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomInfoMessageWidget(
              color: redColor,
              message: 'Qty harus lebih dari 0',
              icons: Icons.error_outline,
            ),
            backgroundColor: whiteColor,
          ),
        );
        return;
      }

      if (qty > max) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomInfoMessageWidget(
              color: redColor,
              message: 'Qty tidak boleh melebihi $max',
              icons: Icons.error_outline,
            ),
            backgroundColor: whiteColor,
          ),
        );
        return;
      }
    }

    // Build request body
    final items = _controllers.entries
        .map(
          (e) => {
            'order_item_id': e.key,
            'shipping_qty': int.parse(e.value.text.trim()),
          },
        )
        .toList();

    final success = await ref
        .read(shipmentViewModelProvider.notifier)
        .updateShipment(widget.shipment.id, items);

    if (success && context.mounted) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      widget.onSuccess();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomInfoMessageWidget(
            color: greenColor,
            message: 'Pengiriman berhasil diubah',
            icons: Icons.error_outline,
          ),
          backgroundColor: whiteColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shipmentViewModelProvider);

    return PopScope(
      canPop: !state.isSubmitting,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Pengiriman',
                    style: boldTextStyle.copyWith(fontSize: 14),
                  ),
                  const Spacer(),
                  if (!state.isSubmitting)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        color: semiSecondaryColor,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ubah jumlah qty barang yang dikirim',
                style: regularTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),

              const SizedBox(height: 16),
              Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),
              const SizedBox(height: 12),

              // List item shipment
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.shipment.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final shipItem = widget.shipment.items[index];
                    final maxQty = _getMaxQty(shipItem.orderItemId);
                    final controller = _controllers[shipItem.orderItemId]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama produk
                        Text(
                          _getProductName(shipItem.orderItemId),
                          style: semiBoldTextStyle.copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Maks qty: $maxQty',
                          style: regularTextStyle.copyWith(
                            fontSize: 11,
                            color: semiSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Input qty + tombol - +
                        Row(
                          children: [
                            // Tombol -
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: () {
                                final current =
                                    int.tryParse(controller.text) ?? 1;
                                if (current > 1) {
                                  setState(() {
                                    controller.text = (current - 1).toString();
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 8),

                            // Input manual
                            Expanded(
                              child: CustomTextfield(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                readOnly: !state.isSubmitting,
                                onChanged: (value) {
                                  final qty = int.tryParse(value);
                                  if (qty != null && qty > maxQty) {
                                    setState(() {
                                      controller.text = maxQty.toString();
                                      controller.selection =
                                          TextSelection.collapsed(
                                            offset: controller.text.length,
                                          );
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Tombol +
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () {
                                final current =
                                    int.tryParse(controller.text) ?? 0;
                                if (current < maxQty) {
                                  setState(() {
                                    controller.text = (current + 1).toString();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Error
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                CustomInfoMessageWidget(
                  color: redColor,
                  message: state.errorMessage!,
                  icons: Icons.error_outline,
                ),
              ],

              const SizedBox(height: 20),

              // Loading
              if (state.isSubmitting) ...[
                LinearProgressIndicator(
                  color: primaryColor,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
              ],

              // Tombol
              if (!state.isSubmitting)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: semiSecondaryColor.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: semiBoldTextStyle.copyWith(
                            color: semiSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onSimpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          style: semiBoldTextStyle.copyWith(color: whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tombol + dan -
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: primaryColor, size: 18),
      ),
    );
  }
}
