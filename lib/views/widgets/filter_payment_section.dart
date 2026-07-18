import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class FilterPaymentSection extends StatelessWidget {
  final int activeFilter;
  final void Function(int) onFilterChanged;

  const FilterPaymentSection({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const List<String> _filters = [
    'Semua',
    'Belum Dibayar',
    'Dibayar Sebagian',
    'Lunas',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = activeFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilterChip(
              onSelected: (_) => onFilterChanged(index),
              label: Text(
                entry.value,
                style: semiBoldTextStyle.copyWith(
                  fontSize: 12,
                  color: isSelected ? whiteColor : semiSecondaryColor,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(
                  color: semiSecondaryColor.withValues(alpha: 0.1),
                ),
              ),
              backgroundColor: whiteColor,
              selectedColor: primaryColor,
              selected: isSelected,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
