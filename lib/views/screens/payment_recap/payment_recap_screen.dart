import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_recap_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_paid_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_pendapatan_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_pesanan_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_detail_total_unpaid_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_card_recap.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_date_range_picker_tile_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentRecapViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: "Rekapitulasi Pembayaran"),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: whiteColor,
        onRefresh: () =>
            ref.read(paymentRecapViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              // Filter date — update viewmodel saat tanggal dipilih
              FilterDateRangePickerTileWidget(
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
                CustomRefreshErrorWidget(
                  message: state.errorMessage!,
                  onPressed: () {
                    ref
                        .read(paymentRecapViewModelProvider.notifier)
                        .loadRecap();
                  },
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
              builder: (context) => PaymentRecapDetailTotalPendapatanScreen(
                startDate: state.startDate,
                endDate: state.endDate,
              ),
            ),
          ),
          child: ItemCardRecap(
            iconSource: "assets/icons/total_pendapatan_icon.png",
            title: "TOTAL PENDAPATAN",
            value: formatRupiah(data.totalPendapatan),
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
              builder: (context) => PaymentRecapDetailTotalPesananScreen(
                startDate: state.startDate,
                endDate: state.endDate,
              ),
            ),
          ),
          child: ItemCardRecap(
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
              builder: (context) => PaymentRecapDetailTotalUnpaidScreen(
                startDate: state.startDate,
                endDate: state.endDate,
              ),
            ),
          ),
          child: ItemCardRecap(
            iconSource: "assets/icons/total_unpaid_icon.png",
            title: "TOTAL BELUM DIBAYAR",
            value: formatRupiah(data.totalUnpaid),
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
          child: ItemCardRecap(
            iconSource: "assets/icons/total_paid_icon.png",
            title: "TOTAL BAYAR",
            value: formatRupiah(data.totalPaid),
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
                    formatRupiah(data.totalPaid),
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
                    formatRupiah(data.totalUnpaid),
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
