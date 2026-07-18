import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/history_transaction_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_history_transaction_section.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_history_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/reusable_advance_filter.dart';

class HistoryTransactionScreen extends ConsumerStatefulWidget {
  const HistoryTransactionScreen({super.key});

  @override
  ConsumerState<HistoryTransactionScreen> createState() =>
      _HistoryTransactionScreenState();
}

class _HistoryTransactionScreenState
    extends ConsumerState<HistoryTransactionScreen> {
  final _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(historyTransactionViewModelProvider);

      if (!state.isLoadMore && !state.hasReachedMax && !state.isLoading) {
        ref
            .read(historyTransactionViewModelProvider.notifier)
            .loadHistory(isLoadMore: true);
      }
    }
  }

  Color _paymentStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => greenColor,
      'partial' => orangeColor,
      _ => semiSecondaryColor,
    };
  }

  Future<void> _onDownload() async {
    final filePath = await ref
        .read(historyTransactionViewModelProvider.notifier)
        .exportToExcel();

    if (filePath != null && mounted) {
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
    final state = ref.watch(historyTransactionViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(
        title: "Riwayat Transaksi",
        actions: [
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                final searchController = TextEditingController(
                  text: state.searchQuery,
                );

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return ReusableAdvanceFilter(
                      title: 'Filter Riwayat',
                      initialStartDate: state.startDate,
                      initialEndDate: state.endDate,
                      initialStatus: state.status,
                      hasActiveFilter: state.hasActiveFilter,

                      customTextFields: [
                        CustomTextfield(
                          controller: searchController,
                          label: 'Pencarian',
                          hintText: 'Cari PO, No Trx, atau Nama...',
                          prefixIcon: Icons.search_rounded,
                        ),
                      ],

                      statusOptions: const [
                        {'label': 'Semua', 'value': ''},
                        {'label': 'Dibayar Sebagian', 'value': 'partial'},
                        {'label': 'Lunas', 'value': 'paid'},
                      ],

                      onApply: (start, end, status) async {
                        await ref
                            .read(historyTransactionViewModelProvider.notifier)
                            .applyAdvanceFilter(
                              startDate: start,
                              endDate: end,
                              status: status,
                              search: searchController.text.trim(),
                            );
                      },

                      onReset: () async {
                        await ref
                            .read(historyTransactionViewModelProvider.notifier)
                            .resetFilter();
                      },
                    );
                  },
                );
              },
              icon: Icon(
                Icons.filter_list_rounded,
                size: 28,
                color: state.hasActiveFilter ? primaryColor : secondaryColor,
              ),
            ),
          ),
          IconButton(
            onPressed: state.isDownloading ? null : _onDownload,
            icon: state.isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                : const Icon(Icons.file_download_outlined, color: primaryColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 2, top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    controller: _searchController,
                    hintText: "Cari nomor PO",
                    prefixIcon: Icons.search,
                    onChanged: (value) => ref
                        .read(historyTransactionViewModelProvider.notifier)
                        .search(value),
                  ),
                ),
                if (_searchController.text.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(historyTransactionViewModelProvider.notifier)
                            .search('');
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            FilterHistoryTransactionSection(
              activeFilter: state.activeFilter,
              onFilterChanged: (index) {
                ref
                    .read(historyTransactionViewModelProvider.notifier)
                    .setFilter(index);
              },
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HistoryTransactionState state) {
    if (state.isLoading && state.filteredTransactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    // Error
    if (state.errorMessage != null && state.filteredTransactions.isEmpty) {
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
      backgroundColor: whiteColor,
      onRefresh: () =>
          ref.read(historyTransactionViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            state.filteredTransactions.length + (state.isLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.filteredTransactions.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            );
          }

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
