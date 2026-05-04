import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';

// Model
enum PaymentStatus { unpaid, partial }

class PaymentItem {
  final String poNumber;
  final String date;
  final int amount;
  final PaymentStatus status;
  bool isSelected;

  PaymentItem({
    required this.poNumber,
    required this.date,
    required this.amount,
    required this.status,
    this.isSelected = false,
  });
}

class MenungguPembayaranWidget extends StatefulWidget {
  const MenungguPembayaranWidget({super.key});

  @override
  State<MenungguPembayaranWidget> createState() =>
      _MenungguPembayaranWidgetState();
}

class _MenungguPembayaranWidgetState extends State<MenungguPembayaranWidget> {
  final TextEditingController _searchController = TextEditingController();

  final List<PaymentItem> _allItems = [
    PaymentItem(
      poNumber: 'P5537XJJ22',
      date: 'Oct 23, 2026',
      amount: 2000000,
      status: PaymentStatus.unpaid,
      isSelected: true,
    ),
    PaymentItem(
      poNumber: 'P2152KPT22',
      date: 'Oct 23, 2026',
      amount: 500000,
      status: PaymentStatus.partial,
      isSelected: true,
    ),
    PaymentItem(
      poNumber: 'P9001ABX11',
      date: 'Oct 24, 2026',
      amount: 1750000,
      status: PaymentStatus.unpaid,
      isSelected: false,
    ),
  ];

  List<PaymentItem> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allItems;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _allItems
          .where((e) => e.poNumber.toLowerCase().contains(query))
          .toList();
    });
  }

  bool get _isAllSelected => _filtered.every((e) => e.isSelected);

  void _toggleAll() {
    setState(() {
      final selectAll = !_isAllSelected;
      for (var item in _filtered) {
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                          color: _isAllSelected
                              ? primaryColor
                              : semiSecondaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: whiteColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                    blurRadius: 0.5,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: mediumTextStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Cari nomor PO',
                  hintStyle: regularTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),

          // List items
          _filtered.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Tidak ada hasil',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final item = _filtered[index];
                    return _PaymentItemTile(
                      item: item,
                      onChanged: (val) => setState(() => item.isSelected = val),
                    );
                  },
                ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Tile per item
class _PaymentItemTile extends StatelessWidget {
  const _PaymentItemTile({required this.item, required this.onChanged});

  final PaymentItem item;
  final ValueChanged<bool> onChanged;

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!item.isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: item.isSelected
                      ? primaryColor
                      : semiSecondaryColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.isSelected
                  ? const Icon(Icons.check, color: whiteColor, size: 14)
                  : null,
            ),

            const SizedBox(width: 14),

            // PO number & date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.poNumber, style: boldTextStyle),
                const SizedBox(height: 6),
                Text(
                  item.date,
                  style: regularTextStyle.copyWith(
                    fontSize: 10,
                    color: semiSecondaryColor,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Amount & status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatRupiah(item.amount),
                  style: boldTextStyle.copyWith(color: primaryColor),
                ),
                const SizedBox(height: 6),
                _StatusBadge(status: item.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Badge status
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      PaymentStatus.unpaid => CustomBadge(
        label: "Unpaid",
        badgeColor: redColor,
      ),
      PaymentStatus.partial => CustomBadge(
        label: "Partial",
        badgeColor: orangeColor,
      ),
    };

    return config;
  }
}
