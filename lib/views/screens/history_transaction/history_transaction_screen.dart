import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/history_transaction_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/history_transaction_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_history_transaction_section.dart';

class HistoryTransactionScreen extends ConsumerStatefulWidget {
  const HistoryTransactionScreen({super.key});

  @override
  ConsumerState<HistoryTransactionScreen> createState() =>
      _HistoryTransactionScreenState();
}

class _HistoryTransactionScreenState
    extends ConsumerState<HistoryTransactionScreen> {
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

  Color _paymentStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => greenColor,
      'partial' => orangeColor,
      'unpaid' => redColor,
      _ => semiSecondaryColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyTransactionViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(
        title: "Laporan Riwayat Transaksi",
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_outlined, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextfield(
              controller: _searchController,
              hintText: "Cari nomor PO",
              prefixIcon: Icons.search,
              onChanged: (value) => ref
                  .read(historyTransactionViewModelProvider.notifier)
                  .search(value),
            ),
            const SizedBox(height: 12),

            FilterHistoryTransactionSection(
              activeFilter: state.activeFilter,
              onFilterChanged: (index) => ref
                  .read(historyTransactionViewModelProvider.notifier)
                  .setFilter(index),
            ),
            const SizedBox(height: 12),

            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HistoryTransactionState state) {
    // Loading
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    // Error
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
                  .read(historyTransactionViewModelProvider.notifier)
                  .loadHistory(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Kosong
    if (state.filteredTransactions.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada riwayat transaksi',
          style: regularTextStyle.copyWith(color: semiSecondaryColor),
        ),
      );
    }

    // List
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () =>
          ref.read(historyTransactionViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.filteredTransactions.length,
        itemBuilder: (context, index) {
          return _HistoryItem(
            item: state.filteredTransactions[index],
            formatRupiah: _formatRupiah,
            paymentStatusColor: _paymentStatusColor,
          );
        },
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final HistoryTransactionModel item;
  final String Function(int) formatRupiah;
  final Color Function(String) paymentStatusColor;

  const _HistoryItem({
    required this.item,
    required this.formatRupiah,
    required this.paymentStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, top: 1, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.5),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header — transaction no, po no, badge status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item.transactionNo} | ${item.poNo}",
                      style: semiBoldTextStyle.copyWith(
                        fontSize: 12,
                        color: primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.customerName.toUpperCase(),
                      style: boldTextStyle.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CustomBadge(
                label: item.paymentStatus,
                badgeColor: paymentStatusColor(item.paymentStatus),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Footer — admin, tanggal, total
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.adminName,
                      style: mediumTextStyle.copyWith(fontSize: 12),
                    ),
                    Text(
                      item.createdAt,
                      style: regularTextStyle.copyWith(
                        fontSize: 12,
                        color: semiSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "JUMLAH TOTAL",
                    style: boldTextStyle.copyWith(
                      fontSize: 10,
                      color: semiSecondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    formatRupiah(item.totalAmount),
                    style: boldTextStyle.copyWith(
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
