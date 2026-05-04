import "package:flutter/material.dart";
import "package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart";
import "package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart";

// Model
class ShippingItem {
  final String name;
  final int price;
  bool isSelected;
  int quantity;

  ShippingItem({
    required this.name,
    required this.price,
    this.isSelected = false,
    this.quantity = 1,
  });
}

class BarangDikirimWidget extends StatefulWidget {
  const BarangDikirimWidget({super.key});

  @override
  State<BarangDikirimWidget> createState() => _BarangDikirimWidgetState();
}

class _BarangDikirimWidgetState extends State<BarangDikirimWidget> {
  final List<ShippingItem> items = [
    ShippingItem(
      name: 'Industrial Bearing 6205',
      price: 1100000,
      isSelected: false,
    ),
    ShippingItem(
      name: 'Conveyor Belt AAA 100398',
      price: 550000,
      isSelected: false,
    ),
    ShippingItem(
      name: 'Chuck Mesin Bubut 320MM 3 Gigi',
      price: 350000,
      isSelected: false,
    ),
  ];

  bool get isAllSelected => items.every((e) => e.isSelected);

  void _toggleAll() {
    setState(() {
      final selectAll = !isAllSelected;
      for (var item in items) {
        item.isSelected = selectAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
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

          // Item list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              return _ShippingItemTile(
                item: items[index],
                onChanged: (val) =>
                    setState(() => items[index].isSelected = val),
                onIncrement: () => setState(() => items[index].quantity++),
                onDecrement: () => setState(() {
                  if (items[index].quantity > 1) items[index].quantity--;
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Tile per item
class _ShippingItemTile extends StatelessWidget {
  const _ShippingItemTile({
    required this.item,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ShippingItem item;
  final ValueChanged<bool> onChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => onChanged(!item.isSelected),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: item.isSelected
                      ? primaryColor
                      : semiSecondaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.isSelected
                  ? const Icon(Icons.check, color: whiteColor, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Name, price, qty
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name.toUpperCase(), style: semiBoldTextStyle),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(item.price),
                  style: boldTextStyle.copyWith(
                    color: primaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),

                // Quantity control
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                      isActive: item.isSelected,
                      color: whiteColor,
                      iconColor: secondaryColor,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${item.quantity}',
                        style: boldTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: onIncrement,
                      isActive: item.isSelected,
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

// Tombol + dan -
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
