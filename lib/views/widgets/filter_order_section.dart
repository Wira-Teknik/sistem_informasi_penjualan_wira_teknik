import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class FilterOrderSection extends StatefulWidget {
  final int activeFilter;
  final void Function(int index) onFilterChanged;
  const FilterOrderSection({
    super.key,
    required this.onFilterChanged,
    required this.activeFilter,
  });

  @override
  State<FilterOrderSection> createState() => _FilterOrderSectionState();
}

class _FilterOrderSectionState extends State<FilterOrderSection> {
  final List<Map<String, dynamic>> _listFilterOrder = [
    {"name": "All"},
    {"name": "Pending"},
    {"name": "Partial"},
    {"name": "Shipped"},
    {"name": "Completed"},
  ];

  int _selectedFilterOrderIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _listFilterOrder.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final isSelected = _selectedFilterOrderIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilterChip(
              onSelected: (value) {
                setState(() {
                  _selectedFilterOrderIndex = index;
                });
                widget.onFilterChanged(index);
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
