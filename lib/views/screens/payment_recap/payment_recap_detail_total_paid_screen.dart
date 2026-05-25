import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_recap_detail_paid_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_card_recap.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_recap_widget.dart';

class PaymentRecapDetailTotalPaidScreen extends ConsumerStatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentRecapDetailTotalPaidScreen({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  ConsumerState<PaymentRecapDetailTotalPaidScreen> createState() =>
      _PaymentRecapDetailTotalPaidScreenState();
}

class _PaymentRecapDetailTotalPaidScreenState
    extends ConsumerState<PaymentRecapDetailTotalPaidScreen> {
  final _searchController = TextEditingController();

  late final _providerKey = (
    startDate: widget.startDate,
    endDate: widget.endDate,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      paymentRecapDetailPaidViewModelProvider(_providerKey),
    );

    return Scaffold(
      appBar: CustomAppbar(
        title: 'Detail Total Paid',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined, color: primaryColor),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => ref
            .read(
              paymentRecapDetailPaidViewModelProvider(_providerKey).notifier,
            )
            .refresh(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Periode waktu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode Waktu',
                        style: boldTextStyle.copyWith(
                          fontSize: 10,
                          color: semiSecondaryColor,
                        ),
                      ),
                      Text(
                        widget.startDate == null && widget.endDate == null
                            ? 'Semua Waktu'
                            : '${formatDateDisplay(widget.startDate)} - ${formatDateDisplay(widget.endDate)}',
                        style: semiBoldTextStyle,
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustomBadge(
                    label: "${state.data?.totalCount ?? 0} Orders",
                    badgeColor: greenColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Card info
              ItemCardRecap(
                iconSource: "assets/icons/total_paid_icon.png",
                title: "TOTAL PAID",
                value: formatRupiah(state.data?.totalPaid ?? 0),
                valueColor: greenColor,
              ),
              const SizedBox(height: 10),

              // Search
              CustomTextfield(
                controller: _searchController,
                hintText: "Cari berdasarkan konsumen, PO",
                prefixIcon: Icons.search,
                onChanged: (value) => ref
                    .read(
                      paymentRecapDetailPaidViewModelProvider(
                        _providerKey,
                      ).notifier,
                    )
                    .search(value),
              ),
              const SizedBox(height: 10),

              // Content
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PaymentRecapDetailPaidState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: regularTextStyle.copyWith(color: semiSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(
                    paymentRecapDetailPaidViewModelProvider(
                      _providerKey,
                    ).notifier,
                  )
                  .loadDetail(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state.filteredItems.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data paid',
          style: regularTextStyle.copyWith(color: semiSecondaryColor),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.filteredItems.length,
      itemBuilder: (context, index) {
        final item = state.filteredItems[index];
        return ItemRecapWidget(
          noPO: item.poNo,
          namaKonsumen: item.customerName,
          tanggal: item.date,
          jumlahTotal: formatRupiah(item.totalAmount),
          badgeName: item.paymentStatus,
          badgeColor: greenColor,
        );
      },
    );
  }
}
