import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class FilterRecapTotalPendapatanSection extends StatefulWidget {
  final void Function(int index) onFilterChanged;
  const FilterRecapTotalPendapatanSection({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<FilterRecapTotalPendapatanSection> createState() =>
      _FilterRecapTotalPendapatanSectionState();
}

class _FilterRecapTotalPendapatanSectionState
    extends State<FilterRecapTotalPendapatanSection> {
  final List<Map<String, dynamic>> _listFilter = [
    {"name": "All"},
    {"name": "Paid"},
    {"name": "Unpaid"},
  ];

  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _listFilter.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilterChip(
              onSelected: (value) {
                setState(() {
                  _selectedFilterIndex = index;
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
