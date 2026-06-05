import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/order_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/add_order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/detail_order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_order_section.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_pesanan_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/reusable_advance_filter.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(
        title: "Pesanan",
        actions: [
          IconButton(
            onPressed: () {
              final poNoController = TextEditingController(text: state.poNo);
              final recipientNameController = TextEditingController(
                text: state.recipientName,
              );

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return ReusableAdvanceFilter(
                    title: 'Filter Pesanan',
                    initialStartDate: state.startDate,
                    initialEndDate: state.endDate,
                    initialStatus: state.orderStatus,
                    hasActiveFilter: state.hasActiveFilter,

                    customTextFields: [
                      CustomTextfield(
                        controller: poNoController,
                        label: 'Nomor PO',
                        hintText: 'Cari nomor PO',
                        prefixIcon: Icons.content_paste_outlined,
                      ),
                      CustomTextfield(
                        controller: recipientNameController,
                        label: 'Nama Konsumen',
                        hintText: 'Cari nama konsumen',
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ],

                    statusOptions: const [
                      {'label': 'All', 'value': ''},
                      {'label': 'Pending', 'value': 'pending'},
                      {'label': 'Partial', 'value': 'partial'},
                      {'label': 'Shipped', 'value': 'shipped'},
                      {'label': 'Completed', 'value': 'completed'},
                    ],

                    onApply: (start, end, status) async {
                      await ref
                          .read(orderViewModelProvider.notifier)
                          .applyAdvanceFilter(
                            startDate: start,
                            endDate: end,
                            orderStatus: status,
                            poNo: poNoController.text.trim(),
                            recipientName: recipientNameController.text.trim(),
                          );
                    },
                    onReset: () async {
                      await ref
                          .read(orderViewModelProvider.notifier)
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
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 2, top: 2),
        child: Column(
          children: [
            // Search
            CustomTextfield(
              controller: _searchController,
              hintText: "Cari nomor PO, nama perusahaan",
              prefixIcon: Icons.search,
              onChanged: (value) =>
                  ref.read(orderViewModelProvider.notifier).search(value),
            ),
            const SizedBox(height: 12),

            // Filter
            FilterOrderSection(
              activeFilter:
                  state.activeFilter, // Mengambil nilai terkini dari state
              onFilterChanged: (index) {
                // Memanggil method setFilter di ViewModel untuk mengubah state
                ref.read(orderViewModelProvider.notifier).setFilter(index);
              },
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddOrderScreen()),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        backgroundColor: primaryColor,
        child: Icon(Icons.add_rounded, color: whiteColor),
      ),
    );
  }

  Widget _buildContent(OrderState state) {
    // Loading pertama kali
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    // Error
    if (state.errorMessage != null) {
      return Center(
        child: CustomRefreshErrorWidget(
          message: state.errorMessage!,
          onPressed: () =>
              ref.read(orderViewModelProvider.notifier).loadOrders(),
        ),
      );
    }

    // Data kosong
    if (state.filteredOrders.isEmpty) {
      return Center(
        child: Text(
          state.activeFilter == 0
              ? 'Belum ada pesanan'
              : 'Tidak ada pesanan dengan filter ini',
        ),
      );
    }

    // List pesanan
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: whiteColor,
      onRefresh: () => ref.read(orderViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.filteredOrders.length,
        itemBuilder: (context, index) {
          final order = state.filteredOrders[index];
          return ItemPesananWidget(
            order: order,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailOrderScreen(order: order),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
