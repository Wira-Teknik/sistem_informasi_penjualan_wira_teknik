import "package:flutter/material.dart";
import "package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart";
import "package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart";
import "package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart";

class BarangDikirimWidget extends StatefulWidget {
  final List<OrderItemModel> items; // ← dari order.items
  final ValueChanged<Map<String, int>> onItemsChanged; // ← {orderItemId: qty}

  const BarangDikirimWidget({
    super.key,
    required this.items,
    required this.onItemsChanged,
  });

  @override
  State<BarangDikirimWidget> createState() => _BarangDikirimWidgetState();
}

class _BarangDikirimWidgetState extends State<BarangDikirimWidget> {
  // Simpan status selected dan qty per item berdasarkan id
  late Map<String, bool> _selected;
  late Map<String, int> _quantities;

  @override
  void initState() {
    super.initState();
    // Default semua dipilih, qty = remainingQty
    _selected = {for (final item in widget.items) item.id: true};
    _quantities = {for (final item in widget.items) item.id: item.remainingQty};
    // Notify parent dengan data awal
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  // Kirim data ke parent — hanya item yang dipilih
  void _notifyParent() {
    final result = <String, int>{};
    for (final item in widget.items) {
      if (_selected[item.id] == true) {
        result[item.id] = _quantities[item.id] ?? 0;
      }
    }
    widget.onItemsChanged(result);
  }

  bool get isAllSelected => _selected.values.every((v) => v == true);

  void _toggleAll() {
    setState(() {
      final selectAll = !isAllSelected;
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

  void _increment(String id, int maxQty) {
    final current = _quantities[id] ?? 0;
    if (current >= maxQty) return; // tidak boleh melebihi remainingQty
    setState(() => _quantities[id] = current + 1);
    _notifyParent();
  }

  void _decrement(String id) {
    final current = _quantities[id] ?? 1;
    if (current <= 1) return;
    setState(() => _quantities[id] = current - 1);
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Barang yang Dikirim', style: semiBoldTextStyle),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleAll,
                      child: Text(
                        'PILIH SEMUA',
                        style: semiBoldTextStyle.copyWith(fontSize: 10),
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
                          color: isAllSelected
                              ? primaryColor
                              : semiSecondaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: semiSecondaryColor.withValues(alpha: 0.1)),

          // Item kosong
          if (widget.items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Tidak ada barang',
                  style: regularTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ),
            ),

          // Item list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isSelected = _selected[item.id] ?? false;
              final qty = _quantities[item.id] ?? 1;

              return _ShippingItemTile(
                item: item,
                isSelected: isSelected,
                quantity: qty,
                onChanged: (val) => _toggleItem(item.id, val),
                onIncrement: () => _increment(item.id, item.remainingQty),
                onDecrement: () => _decrement(item.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShippingItemTile extends StatelessWidget {
  const _ShippingItemTile({
    required this.item,
    required this.isSelected,
    required this.quantity,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final OrderItemModel item;
  final bool isSelected;
  final int quantity;
  final ValueChanged<bool> onChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => onChanged(!isSelected),
            child: AnimatedContainer(
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
                  ? const Icon(Icons.check, color: whiteColor, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Info barang
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName.toUpperCase(), style: semiBoldTextStyle),
                const SizedBox(height: 4),
                // Text(
                //   formatNumberRupiah(item.unitPrice.toString()),
                //   style: boldTextStyle.copyWith(
                //     color: primaryColor,
                //     fontSize: 12,
                //   ),
                // ),
                const SizedBox(height: 10),

                // Quantity control
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                      isActive: isSelected,
                      color: whiteColor,
                      iconColor: secondaryColor,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$quantity',
                        style: boldTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: onIncrement,
                      isActive: isSelected,
                      color: primaryColor,
                      iconColor: whiteColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? color : semiSecondaryColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: semiSecondaryColor.withValues(alpha: 0.5),
              blurRadius: 0.5,
            ),
          ],
        ),
        child: Icon(icon, color: isActive ? iconColor : whiteColor, size: 16),
      ),
    );
  }
}
