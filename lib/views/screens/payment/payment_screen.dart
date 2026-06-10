import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/detail_payment_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/customer_billing_card_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/reusable_advance_filter.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(
        title: "Pembayaran",
        actions: [
          IconButton(
            onPressed: () {
              final nameController = TextEditingController(text: state.name);

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return ReusableAdvanceFilter(
                    title: 'Filter Pembayaran',
                    initialStartDate: state.startDate,
                    initialEndDate: state.endDate,
                    initialStatus: state.status,
                    hasActiveFilter: state.hasActiveFilter,

                    customTextFields: [
                      CustomTextfield(
                        controller: nameController,
                        label: 'Nama Konsumen',
                        hintText: 'Cari nama konsumen',
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ],

                    statusOptions: const [
                      {'label': 'All', 'value': ''},
                      {'label': 'Partial', 'value': 'partial'},
                      {'label': 'Paid', 'value': 'paid'},
                      {'label': 'Unpaid', 'value': 'unpaid'},
                    ],

                    onApply: (start, end, status) async {
                      await ref
                          .read(paymentViewModelProvider.notifier)
                          .applyAdvanceFilter(
                            startDate: start,
                            endDate: end,
                            status: status,
                            name: nameController.text.trim(),
                          );
                    },

                    onReset: () async {
                      await ref
                          .read(paymentViewModelProvider.notifier)
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
            Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    controller: _searchController,
                    hintText: "Cari nama perusahaan",
                    textCapitalization: TextCapitalization.characters,
                    prefixIcon: Icons.search,
                    onChanged: (value) => ref
                        .read(paymentViewModelProvider.notifier)
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
                        ref.read(paymentViewModelProvider.notifier).search('');
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 22),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PaymentState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (state.errorMessage != null) {
      return Center(
        child: CustomRefreshErrorWidget(
          message: state.errorMessage!,
          onPressed: () =>
              ref.read(paymentViewModelProvider.notifier).loadBillings(),
        ),
      );
    }

    if (state.filteredBillings.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data tagihan',
          style: regularTextStyle.copyWith(color: semiSecondaryColor),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: whiteColor,
      onRefresh: () => ref.read(paymentViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.filteredBillings.length,
        itemBuilder: (context, index) {
          return CustomerBillingCardWidget(
            billing: state.filteredBillings[index],
            formatRupiah: formatRupiah,
            formatDate: formatDate,
            onOrderTap: (order) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPaymentScreen(
                    customerName: state.filteredBillings[index].customerName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
