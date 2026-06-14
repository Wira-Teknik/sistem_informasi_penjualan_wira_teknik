import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class FilterHistoryTransactionSection extends StatelessWidget {
  final int activeFilter;
  final void Function(int index) onFilterChanged;

  const FilterHistoryTransactionSection({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> listFilterHistory = [
      {"name": "All"},
      {"name": "Partial"},
      {"name": "Paid"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: listFilterHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final isSelected = activeFilter == index;

          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilterChip(
              onSelected: (value) {
                onFilterChanged(index);
              },
              label: Text(
                e["name"].toString(),
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
