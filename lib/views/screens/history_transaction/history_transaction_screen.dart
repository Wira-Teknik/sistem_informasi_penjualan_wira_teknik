import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/history_transaction_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_history_transaction_section.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_history_widget.dart';

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
      return CustomRefreshErrorWidget(
        message: state.errorMessage!,
        onPressed: () => ref
            .read(historyTransactionViewModelProvider.notifier)
            .loadHistory(),
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
          return ItemHistoryWidget(
            item: state.filteredTransactions[index],
            formatRupiah: formatRupiah,
            paymentStatusColor: _paymentStatusColor,
          );
        },
      ),
    );
  }
}
