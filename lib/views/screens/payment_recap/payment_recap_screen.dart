import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_recap_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_paid_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_pendapatan_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_pesanan_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_unpaid_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/card_recap_item.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class PaymentRecapScreen extends ConsumerStatefulWidget {
  const PaymentRecapScreen({super.key});

  @override
  ConsumerState<PaymentRecapScreen> createState() => _PaymentRecapScreenState();
}

class _PaymentRecapScreenState extends ConsumerState<PaymentRecapScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentRecapViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: "Rekapitulasi Pembayaran"),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () =>
            ref.read(paymentRecapViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              // Filter date — update viewmodel saat tanggal dipilih
              DateRangePickerTile(
                startDate: state.startDate,
                endDate: state.endDate,
                onDateRangeChanged: (start, end) {
                  ref
                      .read(paymentRecapViewModelProvider.notifier)
                      .setDateRange(start, end);
                },
              ),
              const SizedBox(height: 10),

              // Search
              CustomTextfield(
                controller: _searchController,
                hintText: "Cari berdasarkan konsumen",
                prefixIcon: Icons.search,
                onChanged: (value) => ref
                    .read(paymentRecapViewModelProvider.notifier)
                    .search(value),
              ),
              const SizedBox(height: 20),

              // Loading
              if (state.isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              // Error
              else if (state.errorMessage != null)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          style: regularTextStyle.copyWith(
                            color: semiSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(paymentRecapViewModelProvider.notifier)
                              .loadRecap(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              // Data
              else if (state.data != null)
                _buildContent(context, state),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentRecapState state) {
    final data = state.data!;
    final unpaidPercent = data.lunasPercentage;
    final paidPercent = 100 - unpaidPercent;

    return Column(
      children: [
        // Card total pendapatan
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const PaymentRecapDetailTotalPendapatanScreen(),
            ),
          ),
          child: CardRecapItem(
            iconSource: "assets/icons/total_pendapatan_icon.png",
            title: "TOTAL PENDAPATAN",
            value: _formatRupiah(data.totalPendapatan),
            valueColor: primaryColor,
            isArrowIconVisible: true,
            arrowIconColor: primaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // Card total pesanan
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const PaymentRecapDetailTotalPesananScreen(),
            ),
          ),
          child: CardRecapItem(
            iconSource: "assets/icons/rekap_pesanan_icon.png",
            title: "TOTAL PESANAN",
            value: "${data.totalPesananCount} Orders",
            valueColor: secondaryColor,
            isArrowIconVisible: true,
            arrowIconColor: secondaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // Card total unpaid
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentRecapDetailTotalUnpaidScreen(),
            ),
          ),
          child: CardRecapItem(
            iconSource: "assets/icons/total_unpaid_icon.png",
            title: "TOTAL UNPAID",
            value: _formatRupiah(data.totalUnpaid),
            valueColor: redColor,
            isArrowIconVisible: true,
            arrowIconColor: redColor,
          ),
        ),
        const SizedBox(height: 10),

        // Card total paid
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentRecapDetailTotalPaidScreen(),
            ),
          ),
          child: CardRecapItem(
            iconSource: "assets/icons/total_paid_icon.png",
            title: "TOTAL PAID",
            value: _formatRupiah(data.totalPaid),
            valueColor: greenColor,
            isArrowIconVisible: true,
            arrowIconColor: greenColor,
          ),
        ),
        const SizedBox(height: 20),

        // Chart pie
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: semiSecondaryColor.withValues(alpha: 0.5),
                blurRadius: 0.5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Status Pelunasan Piutang",
                    style: boldTextStyle.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/icons/chart_icon.png",
                    width: 18,
                    height: 18,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: paidPercent > 0 ? paidPercent : 0.01,
                              color: primaryColor,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: unpaidPercent > 0 ? unpaidPercent : 0.01,
                              color: Colors.grey.shade200,
                              showTitle: false,
                            ),
                          ],
                          sectionsSpace: 0,
                          centerSpaceRadius: 80,
                        ),
                      ),

                      // Center label
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${paidPercent.toStringAsFixed(1)}%',
                            style: boldTextStyle.copyWith(fontSize: 24),
                          ),
                          Text(
                            'Lunas',
                            style: boldTextStyle.copyWith(
                              fontSize: 12,
                              color: semiSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Legend paid
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Lunas (Paid)",
                    style: mediumTextStyle.copyWith(color: semiSecondaryColor),
                  ),
                  const Spacer(),
                  Text(
                    _formatRupiah(data.totalPaid),
                    style: boldTextStyle.copyWith(
                      fontSize: 16,
                      color: greenColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Legend unpaid
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: semiSecondaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Piutang (Unpaid)",
                    style: mediumTextStyle.copyWith(color: semiSecondaryColor),
                  ),
                  const Spacer(),
                  Text(
                    _formatRupiah(data.totalUnpaid),
                    style: boldTextStyle.copyWith(
                      fontSize: 16,
                      color: redColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DateRangePickerTile extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end) onDateRangeChanged;

  const DateRangePickerTile({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  State<DateRangePickerTile> createState() => _DateRangePickerTileState();
}

class _DateRangePickerTileState extends State<DateRangePickerTile> {
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
