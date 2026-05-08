import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_paid_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_pendapatan_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_pesanan_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_unpaid_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/card_recap_item.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class PaymentRecapScreen extends StatelessWidget {
  const PaymentRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Rekapitulasi Pembayaran"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            // filter date
            DateRangePickerTile(),
            const SizedBox(height: 10),

            // search bar
            CustomTextfield(
              hintText: "Cari berdasarkan konsumen",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 20),

            // card total pendapatan
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
                value: "Rp 45.200.000",
                valueColor: primaryColor,
                isArrowIconVisible: true,
                arrowIconColor: primaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // card total pesanan
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
                value: "142 Orders",
                valueColor: secondaryColor,
                isArrowIconVisible: true,
                arrowIconColor: secondaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // card total unpaid
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PaymentRecapDetailTotalUnpaidScreen(),
                ),
              ),
              child: CardRecapItem(
                iconSource: "assets/icons/total_unpaid_icon.png",
                title: "TOTAL UNPAID",
                value: "Rp 12.800.000",
                valueColor: redColor,
                isArrowIconVisible: true,
                arrowIconColor: redColor,
              ),
            ),
            const SizedBox(height: 10),

            // card total paid
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PaymentRecapDetailTotalPaidScreen(),
                ),
              ),
              child: CardRecapItem(
                iconSource: "assets/icons/total_paid_icon.png",
                title: "TOTAL PAID",
                value: "Rp 32.400.000",
                valueColor: greenColor,
                isArrowIconVisible: true,
                arrowIconColor: greenColor,
              ),
            ),
            const SizedBox(height: 20),

            // chart status pelunasan piutang
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
                                  value: 71.6,
                                  color: primaryColor,
                                  showTitle: false,
                                ),
                                // Add remaining portion so the donut looks complete
                                PieChartSectionData(
                                  value: 28.4,
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
                                '71.6%',
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
                        style: mediumTextStyle.copyWith(
                          color: semiSecondaryColor,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Rp 32.400.000",
                        style: boldTextStyle.copyWith(
                          fontSize: 16,
                          color: greenColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

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
                        style: mediumTextStyle.copyWith(
                          color: semiSecondaryColor,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Rp 12.800.000",
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
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class DateRangePickerTile extends StatefulWidget {
  const DateRangePickerTile({super.key});

  @override
  State<DateRangePickerTile> createState() => _DateRangePickerTileState();
}

class _DateRangePickerTileState extends State<DateRangePickerTile> {
  DateTime? startDate = DateTime(2026, 1, 1);
  DateTime? endDate = DateTime.now();

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = (startDate != null && endDate != null)
        ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
        : 'Select date range';

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
            // Calendar icon
            const Icon(
              Icons.calendar_today_outlined,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),

            // Label + Date
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

            // Chevron
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
