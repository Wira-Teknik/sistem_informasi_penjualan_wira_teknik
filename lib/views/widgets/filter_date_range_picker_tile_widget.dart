import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class FilterDateRangePickerTileWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end) onDateRangeChanged;

  const FilterDateRangePickerTileWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  State<FilterDateRangePickerTileWidget> createState() =>
      _FilterDateRangePickerTileWidgetState();
}

class _FilterDateRangePickerTileWidgetState
    extends State<FilterDateRangePickerTileWidget> {
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      // Kirim ke viewmodel
      widget.onDateRangeChanged(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = (_startDate != null && _endDate != null)
        ? '${_formatDate(_startDate)} - ${_formatDate(_endDate)}'
        : 'Pilih periode waktu';

    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PERIODE WAKTU',
                    style: boldTextStyle.copyWith(
                      fontSize: 10,
                      color: semiSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(dateText, style: semiBoldTextStyle),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: primaryColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
