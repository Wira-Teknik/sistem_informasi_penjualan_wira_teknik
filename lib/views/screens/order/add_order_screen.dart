import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_order_request_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/customer_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/order_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class AddOrderScreen extends ConsumerStatefulWidget {
  const AddOrderScreen({super.key});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _poNoController = TextEditingController();
  final _orderDateController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // State untuk list item barang
  final List<AddOrderItemRequest> _items = [];

  // Controller sementara untuk input barang
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemQtyController = TextEditingController();

  // Customer yang dipilih
  CustomerModel? _selectedCustomer;

  // Method auto-fill dari customer yang dipilih
  void _fillFromCustomer(CustomerModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _nameController.text = customer.customerName;
      _phoneController.text = customer.customerPhone;
      _emailController.text = customer.customerEmail;
      _addressController.text = customer.customerAddress;
    });
  }

  // ignore: unused_field
  DateTime? _selectedDate;

  @override
  void dispose() {
    _poNoController.dispose();
    _orderDateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemQtyController.dispose();
    super.dispose();
  }

  // Pilih tanggal
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _orderDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Tambah barang ke list
  void _addItem() {
    final name = _itemNameController.text.trim();
    final price = double.tryParse(
      _itemPriceController.text.replaceAll('.', ''),
    );
    final qty = int.tryParse(_itemQtyController.text.trim());

    if (name.isEmpty) {
      _showSnackbar('Nama barang wajib diisi', isError: true);
      return;
    }
    if (price == null || price <= 0) {
      _showSnackbar('Harga tidak valid', isError: true);
      return;
    }
    if (qty == null || qty <= 0) {
      _showSnackbar('Jumlah tidak valid', isError: true);
      return;
    }

    setState(() {
      _items.add(
        AddOrderItemRequest(productName: name, unitPrice: price, orderQty: qty),
      );

      // Reset input barang
      _itemNameController.clear();
      _itemPriceController.clear();
      _itemQtyController.clear();
    });
  }

  // Hapus barang dari list
  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _onBuatPesanan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      _showSnackbar('Tambahkan minimal 1 barang', isError: true);
      return;
    }

    final request = AddOrderRequest(
      poNo: _poNoController.text.trim(),
      orderDate: _orderDateController.text.trim(),
      recipientName: _nameController.text.trim(),
      recipientEmail: _emailController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      recipientAddress: _addressController.text.trim(),
      items: _items,
    );

    final success = await ref
        .read(orderViewModelProvider.notifier)
        .addOrder(request);

    if (success && mounted) {
      _showSnackbar('Pesanan berhasil dibuat', isError: false);
      Navigator.pop(context);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomInfoMessageWidget(
          color: isError ? redColor : greenColor,
          message: message,
          icons: isError ? Icons.error_outline_outlined : Icons.check_rounded,
        ),
        backgroundColor: whiteColor,
      ),
    );
  }

  // Format angka rupiah saat mengetik
  String _formatNumber(String value) {
    final clean = value.replaceAll('.', '');
    if (clean.isEmpty) return '';
    final number = int.tryParse(clean) ?? 0;
    return NumberFormat('#,###', 'id_ID').format(number);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderViewModelProvider);

    return PopScope(
      canPop: !state.isSubmitting,
      child: Scaffold(
        appBar: CustomAppbar(title: "Pesanan Baru"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 17, right: 17, bottom: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── Detail Pesanan ──────────────────────────
                _buildSectionHeader(
                  "assets/icons/order_detail_icon.png",
                  "DETAIL PESANAN",
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _poNoController,
                  label: "Nomor PO",
                  prefixIcon: Icons.content_paste_outlined,
                  hintText: "PO-2026-001",
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nomor PO wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Tanggal dengan date picker
                CustomTextfield(
                  controller: _orderDateController,
                  label: "Tanggal Pesan",
                  prefixIcon: Icons.calendar_today_outlined,
                  hintText: "Pilih tanggal",
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tanggal wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                // ── Informasi Konsumen ──────────────────────
                _buildSectionHeader(
                  "assets/icons/customer_information_icon.png",
                  "INFORMASI KONSUMEN",
                ),
                const SizedBox(height: 16),

                // Tombol pilih dari daftar customer
                Text("Nama Konsumen", style: semiBoldTextStyle),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _CustomerPickerSheet(
                        selectedCustomer: _selectedCustomer,
                        onSelected: (customer) {
                          _fillFromCustomer(
                            customer,
                          ); // ← auto-fill semua field
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: semiSecondaryColor.withValues(alpha: 0.5),
                          blurRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: semiSecondaryColor.withValues(alpha: 0.5),
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _selectedCustomer == null
                              ? "Pilih dari daftar konsumen"
                              : "Konsumen: ${_selectedCustomer!.customerName}",
                          style: mediumTextStyle.copyWith(
                            color: secondaryColor,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _phoneController,
                  label: "Nomor Telepon",
                  prefixIcon: Icons.phone_outlined,
                  hintText: "08....",
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Nomor telepon wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _emailController,
                  label: "Alamat Email",
                  prefixIcon: Icons.mail_outline_outlined,
                  hintText: "email@mail.com",
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _addressController,
                  label: "Alamat Pengiriman",
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                // ── Barang Pesanan ──────────────────────────
                _buildSectionHeader(
                  "assets/icons/order_items_icon.png",
                  "BARANG PESANAN",
                ),
                const SizedBox(height: 16),

                // Input tambah barang
                CustomTextfield(
                  controller: _itemNameController,
                  label: "Nama Barang",
                  hintText: "Bearing SKF 6205",
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextfield(
                        controller: _itemPriceController,
                        label: "Harga",
                        hintText: "75.000",
                        prefixIcon: Icons.money_rounded,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final formatted = _formatNumber(value);
                          if (formatted != value) {
                            _itemPriceController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 126,
                      child: CustomTextfield(
                        controller: _itemQtyController,
                        label: "Jumlah",
                        hintText: "1",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomFilledbutton(
                  title: "Tambah Barang",
                  iconButton: Icons.add_rounded,
                  buttonColor: secondaryColor,
                  onPressed: _addItem,
                ),
                const SizedBox(height: 16),

                // List barang yang sudah ditambahkan
                if (_items.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: semiSecondaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_items.length} barang ditambahkan",
                          style: semiBoldTextStyle.copyWith(
                            fontSize: 12,
                            color: semiSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: semiBoldTextStyle,
                                      ),
                                      Text(
                                        "${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(item.unitPrice)} × ${item.orderQty}",
                                        style: regularTextStyle.copyWith(
                                          fontSize: 12,
                                          color: semiSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Total per item
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(item.unitPrice * item.orderQty),
                                  style: semiBoldTextStyle.copyWith(
                                    color: primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Hapus item
                                GestureDetector(
                                  onTap: () => _removeItem(index),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: redColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        Divider(
                          color: semiSecondaryColor.withValues(alpha: 0.2),
                        ),

                        // Grand total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("TOTAL", style: boldTextStyle),
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(
                                _items.fold<double>(
                                  0,
                                  (sum, item) =>
                                      sum + (item.unitPrice * item.orderQty),
                                ),
                              ),
                              style: boldTextStyle.copyWith(
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Error dari API
                if (state.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                // Tombol submit
                state.isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : CustomFilledbutton(
                        title: "Buat Pesanan",
                        iconButton: Icons.save_rounded,
                        onPressed: _onBuatPesanan,
                      ),
                const SizedBox(height: 12),

                CustomFilledbutton(
                  title: "Batalkan",
                  buttonColor: semiSecondaryColor.withValues(alpha: 0.1),
                  titleButtonColor: semiSecondaryColor,
                  onPressed: state.isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String iconPath, String title) {
    return Row(
      children: [
        Image.asset(iconPath, width: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: semiBoldTextStyle.copyWith(color: semiSecondaryColor),
        ),
      ],
    );
  }
}

class _CustomerPickerSheet extends ConsumerStatefulWidget {
  final CustomerModel? selectedCustomer;
  final ValueChanged<CustomerModel> onSelected;

  const _CustomerPickerSheet({
    required this.selectedCustomer,
    required this.onSelected,
  });

  @override
  ConsumerState<_CustomerPickerSheet> createState() =>
      _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<_CustomerPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  onTap: () => Navigator.pop(context),
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
          const SizedBox(height: 12),

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
        ],
      ),
    );
  }
}
