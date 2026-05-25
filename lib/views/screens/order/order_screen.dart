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
      appBar: CustomAppbar(title: "Pesanan"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
              activeFilter: state.activeFilter,
              onFilterChanged: (index) =>
                  ref.read(orderViewModelProvider.notifier).setFilter(index),
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
