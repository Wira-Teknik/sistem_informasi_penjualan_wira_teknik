import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/customer_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/customer/add_customer_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class CustomCustomerPickerSheetWidget extends ConsumerStatefulWidget {
  final CustomerModel? selectedCustomer;
  final ValueChanged<CustomerModel> onSelected;

  const CustomCustomerPickerSheetWidget({
    super.key,
    required this.selectedCustomer,
    required this.onSelected,
  });

  @override
  ConsumerState<CustomCustomerPickerSheetWidget> createState() =>
      _CustomCustomerPickerSheetWidgetState();
}

class _CustomCustomerPickerSheetWidgetState
    extends ConsumerState<CustomCustomerPickerSheetWidget> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerViewModelProvider.notifier).clearFilteredCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewModelProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: semiSecondaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "Pilih Konsumen",
                  style: boldTextStyle.copyWith(fontSize: 16),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(customerViewModelProvider.notifier)
                        .clearFilteredCustomers();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close_rounded, color: semiSecondaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomTextfield(
              controller: _searchController,
              hintText: "Cari nama konsumen",
              prefixIcon: Icons.search,
              onChanged: (value) =>
                  ref.read(customerViewModelProvider.notifier).search(value),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCustomerScreen(),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  overlayColor: primaryColor.withValues(alpha: 0.1),
                ),
                child: Text(
                  "Belum ada pelanggan? Tambah baru",
                  style: regularTextStyle.copyWith(
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),

          // List customer
          Expanded(
            child: state.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : state.filteredCustomers.isEmpty
                ? Center(
                    child: Text(
                      'Konsumen tidak ditemukan',
                      style: regularTextStyle.copyWith(
                        color: semiSecondaryColor,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filteredCustomers.length,
                    separatorBuilder: (_, _) => Divider(
                      color: semiSecondaryColor.withValues(alpha: 0.1),
                    ),
                    itemBuilder: (context, index) {
                      final customer = state.filteredCustomers[index];
                      final isSelected =
                          widget.selectedCustomer?.id == customer.id;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            customer.customerName[0].toUpperCase(),
                            style: boldTextStyle.copyWith(color: primaryColor),
                          ),
                        ),
                        title: Text(
                          customer.customerName,
                          style: semiBoldTextStyle,
                        ),
                        subtitle: Text(
                          customer.customerEmail,
                          style: regularTextStyle.copyWith(
                            fontSize: 12,
                            color: semiSecondaryColor,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: primaryColor,
                              )
                            : null,
                        onTap: () => widget.onSelected(customer),
                      );
                    },
                  ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
