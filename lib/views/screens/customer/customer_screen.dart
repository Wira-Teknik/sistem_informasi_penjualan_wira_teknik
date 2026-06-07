import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/customer_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/customer/add_customer_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/customer/edit_customer_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_card_customer_widget.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: 'Daftar Konsumen'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search bar
            CustomTextfield(
              controller: _searchController,
              hintText: "Cari nama perusahaan / konsumen",
              prefixIcon: Icons.search,
              onChanged: (value) =>
                  ref.read(customerViewModelProvider.notifier).search(value),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(child: _buildContent(state)),
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerScreen()),
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

  Widget _buildContent(CustomerState state) {
    // Loading pertama kali
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    // Error
    if (state.errorMessage != null) {
      return CustomRefreshErrorWidget(
        message: state.errorMessage!,
        onPressed: () =>
            ref.read(customerViewModelProvider.notifier).loadCustomers(),
      );
    }

    // Hasil search kosong
    if (state.filteredCustomers.isEmpty) {
      return Center(
        child: Text(
          'Konsumen tidak ditemukan',
          style: regularTextStyle.copyWith(color: semiSecondaryColor),
        ),
      );
    }

    // List customer
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () => ref.read(customerViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.filteredCustomers.length,
        itemBuilder: (context, index) {
          return ItemCardCustomerWidget(
            customer: state.filteredCustomers[index],
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCustomerScreen(
                    customer: state.filteredCustomers[index],
                  ),
                ),
              );
            },
            onDelete: () => _showDeleteDialog(state.filteredCustomers[index]),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Konsumen', style: boldTextStyle),
        backgroundColor: whiteColor,
        content: Text(
          'Apakah Anda yakin ingin menghapus ${customer.customerName}?',
          style: mediumTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: semiBoldTextStyle.copyWith(color: primaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await ref
                  .read(customerViewModelProvider.notifier)
                  .deleteCustomer(customer.id);

              if (success && mounted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: CustomInfoMessageWidget(
                      color: greenColor,
                      message: 'Konsumen berhasil dihapus',
                      icons: Icons.check_circle_outline_outlined,
                    ),
                    backgroundColor: whiteColor,
                  ),
                );
              }
            },
            child: Text(
              'Hapus',
              style: semiBoldTextStyle.copyWith(color: redColor),
            ),
          ),
        ],
      ),
    );
  }
}
