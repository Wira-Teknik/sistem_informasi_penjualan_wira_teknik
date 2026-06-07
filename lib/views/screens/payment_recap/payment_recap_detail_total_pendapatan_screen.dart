import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_recap_detail_pendapatan_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_card_recap.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_recap_total_pendapatan_section.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_recap_widget.dart';

class PaymentRecapDetailTotalPendapatanScreen extends ConsumerStatefulWidget {
  // ← Parameter dari payment_recap_screen
  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentRecapDetailTotalPendapatanScreen({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  ConsumerState<PaymentRecapDetailTotalPendapatanScreen> createState() =>
      _PaymentRecapDetailTotalPendapatanScreenState();
}

class _PaymentRecapDetailTotalPendapatanScreenState
    extends ConsumerState<PaymentRecapDetailTotalPendapatanScreen> {
  final _searchController = TextEditingController();

  // Key provider dengan parameter tanggal dari screen sebelumnya
  late final _providerKey = (
    startDate: widget.startDate,
    endDate: widget.endDate,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _paymentStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => greenColor,
      'partial' => orangeColor,
      'unpaid' => redColor,
      _ => semiSecondaryColor,
    };
  }

  Future<void> _onDownload() async {
    final filePath = await ref
        .read(
          paymentRecapDetailPendapatanViewModelProvider(_providerKey).notifier,
        )
        .exportToExcel();

    if (filePath != null && mounted) {
      // Buka file
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomInfoMessageWidget(
              color: orangeColor,
              message: 'Tidak bisa membuka file: ${result.message}',
              icons: Icons.warning_amber_rounded,
            ),
            backgroundColor: whiteColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      paymentRecapDetailPendapatanViewModelProvider(_providerKey),
    );

    return Scaffold(
      appBar: CustomAppbar(
        title: 'Detail Total Pendapatan',
        actions: [
          IconButton(
            onPressed: state.isDownloading ? null : _onDownload,
            icon: state.isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                : const Icon(Icons.file_download_outlined, color: primaryColor),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => ref
            .read(
              paymentRecapDetailPendapatanViewModelProvider(
                _providerKey,
              ).notifier,
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
                    label: "${state.data?.totalPesananCount ?? 0} Orders",
                    badgeColor: primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Card info
              ItemCardRecap(
                iconSource: "assets/icons/total_pendapatan_icon.png",
                title: "TOTAL PENDAPATAN",
                value: formatRupiah(state.data?.totalPendapatan ?? 0),
                valueColor: primaryColor,
              ),
              const SizedBox(height: 10),

              // Search
              CustomTextfield(
                controller: _searchController,
                hintText: "Cari berdasarkan konsumen",
                prefixIcon: Icons.search,
                onChanged: (value) => ref
                    .read(
                      paymentRecapDetailPendapatanViewModelProvider(
                        _providerKey,
                      ).notifier,
                    )
                    .search(value),
              ),
              const SizedBox(height: 10),

              // Filter
              FilterRecapTotalPendapatanSection(
                activeFilter: state.activeFilter,
                onFilterChanged: (index) => ref
                    .read(
                      paymentRecapDetailPendapatanViewModelProvider(
                        _providerKey,
                      ).notifier,
                    )
                    .setFilter(index),
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

  Widget _buildContent(PaymentRecapDetailPendapatanState state) {
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
                    paymentRecapDetailPendapatanViewModelProvider(
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
          'Tidak ada data pendapatan',
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
          badgeColor: _paymentStatusColor(item.paymentStatus),
        );
      },
    );
  }
}
