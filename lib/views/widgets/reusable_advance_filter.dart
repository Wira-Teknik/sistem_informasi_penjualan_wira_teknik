import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_date_range_picker_tile_widget.dart';

class ReusableAdvanceFilter extends StatefulWidget {
  final String title;
  final bool showDateRange;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<CustomTextfield> customTextFields;
  final List<Map<String, String>> statusOptions;
  final String initialStatus;
  final bool hasActiveFilter;
  final Future<void> Function(
    DateTime? startDate,
    DateTime? endDate,
    String status,
  )
  onApply;

  final Future<void> Function() onReset;

  const ReusableAdvanceFilter({
    super.key,
    this.title = 'Filter Pencarian',
    this.showDateRange = true,
    this.initialStartDate,
    this.initialEndDate,
    this.customTextFields = const [],
    this.statusOptions = const [],
    this.initialStatus = '',
    this.hasActiveFilter = false,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ReusableAdvanceFilter> createState() => _ReusableAdvanceFilterState();
}

class _ReusableAdvanceFilterState extends State<ReusableAdvanceFilter> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedStatus = widget.initialStatus;
  }

  Future<void> _handleApply() async {
    setState(() => _isLoading = true);
    await widget.onApply(_startDate, _endDate, _selectedStatus);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  Future<void> _handleReset() async {
    setState(() => _isLoading = true);
    await widget.onReset();

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle drag
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: semiSecondaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(widget.title, style: boldTextStyle.copyWith(fontSize: 16)),
                const Spacer(),
                if (widget.hasActiveFilter)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Filter Aktif',
                      style: semiBoldTextStyle.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
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
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: semiSecondaryColor.withValues(alpha: 0.1)),

          // Konten filter (Scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. DATE RANGE ---
                  if (widget.showDateRange) ...[
                    Text(
                      'Periode Tanggal',
                      style: semiBoldTextStyle.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    FilterDateRangePickerTileWidget(
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateRangeChanged: (start, end) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- 2. CUSTOM TEXT FIELDS ---
                  // Menampilkan widget CustomTextfield yang dikirim dari parent
                  ...widget.customTextFields.map((textField) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: textField,
                    );
                  }),

                  // --- 3. STATUS OPTIONS ---
                  if (widget.statusOptions.isNotEmpty) ...[
                    Text(
                      'Status',
                      style: semiBoldTextStyle.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.statusOptions.map((option) {
                        final isSelected = _selectedStatus == option['value'];
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedStatus = option['value']!,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : semiSecondaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : semiSecondaryColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              option['label']!,
                              style: semiBoldTextStyle.copyWith(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : semiSecondaryColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // --- TOMBOL AKSI ---
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).viewInsets.bottom + 16, // Tangani keyboard
            ),
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleReset,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: semiSecondaryColor.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: semiBoldTextStyle.copyWith(
                              color: semiSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CustomFilledbutton(
                          title: 'Terapkan Filter',
                          buttonRadius: 12,
                          onPressed: _handleApply,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
