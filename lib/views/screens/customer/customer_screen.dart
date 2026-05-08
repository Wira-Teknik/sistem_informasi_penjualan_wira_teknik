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
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: redColor),
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: regularTextStyle.copyWith(color: semiSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(customerViewModelProvider.notifier).loadCustomers(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
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
          return _CustomerCard(
            customer: state.filteredCustomers[index],
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCustomerScreen(
                    customer:
                        state.filteredCustomers[index], // ← kirim data customer
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

// Card customer — dipisah agar tidak rebuild seluruh list
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomerModel customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.5),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Nama customer
          Row(
            children: [
              Image.asset(
                "assets/icons/building_icon.png",
                width: 20,
                height: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer.customerName.toUpperCase(),
                  style: boldTextStyle.copyWith(
                    fontSize: 16,
                    color: primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Email
          Row(
            children: [
              Icon(Icons.mail_outline, size: 20, color: secondaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer.customerEmail,
                  style: regularTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Telepon
          Row(
            children: [
              Icon(Icons.call_outlined, size: 20, color: secondaryColor),
              const SizedBox(width: 8),
              Text(customer.customerPhone, style: regularTextStyle),
            ],
          ),
          const SizedBox(height: 8),

          Divider(color: secondaryColor.withValues(alpha: 0.1)),
          const SizedBox(height: 4),

          // Alamat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/icons/location_icon.png",
                width: 20,
                height: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  customer.customerAddress,
                  style: regularTextStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tombol aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: IconButton(
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 24,
                width: 24,
                child: IconButton(
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.delete_outline, color: redColor, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
