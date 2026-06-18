import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_order_request_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/order_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_customer_picker_sheet_widget.dart';
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

  // ignore: unused_field
  DateTime? _selectedDate;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderViewModelProvider.notifier).fetchNextTransactionNo();
    });
  }

  // Pilih tanggal
  Future<void> _pickDate() async {
    final picked = await pickCustomDate(context, firstDate: DateTime.now());
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _orderDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Tambah barang ke list
  void _addItem() {
    final name = _itemNameController.text.trim().toUpperCase();
    final price = double.tryParse(
      _itemPriceController.text.replaceAll('.', ''),
    );
    final qty = int.tryParse(_itemQtyController.text.trim());

    if (name.isEmpty) {
      showSnackbar(context, 'Nama barang wajib diisi', isError: true);
      return;
    }
    if (price == null || price <= 0) {
      showSnackbar(context, 'Harga tidak valid', isError: true);
      return;
    }
    if (qty == null || qty <= 0) {
      showSnackbar(context, 'Jumlah tidak valid', isError: true);
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

  Future<void> _onBuatPesanan(String transactionNumber) async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      showSnackbar(context, 'Tambahkan minimal 1 barang', isError: true);
      return;
    }

    final request = AddOrderRequest(
      transactionNumber: transactionNumber,
      poNo: _poNoController.text.trim().toUpperCase(),
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
      showSnackbar(context, 'Pesanan berhasil dibuat', isError: false);
      Navigator.pop(context);
    }
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

                Text("Nomor Transaksi", style: semiBoldTextStyle),
                const SizedBox(height: 8),
                _buildTrxNoField(state),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _poNoController,
                  label: "Nomor PO",
                  prefixIcon: Icons.assignment_outlined,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.characters,
                  hintText: "Masukkan Nomor PO",
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nomor PO wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Tanggal dengan date picker
                CustomTextfield(
                  controller: _orderDateController,
                  label: "Tanggal Pesan",
                  prefixIcon: Icons.calendar_today_outlined,
                  hintText: "Pilih Tanggal",
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
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CustomCustomerPickerSheetWidget(
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
                        SizedBox(
                          width: 220,
                          child: Text(
                            _selectedCustomer == null
                                ? "Pilih dari daftar konsumen"
                                : "Konsumen: ${_selectedCustomer!.customerName}",
                            overflow: TextOverflow.ellipsis,
                            style: mediumTextStyle.copyWith(
                              color: secondaryColor,
                              fontSize: 14,
                            ),
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
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.visiblePassword,
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
                          final formatted = formatNumberRupiah(value);
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
                  CustomInfoMessageWidget(
                    color: redColor,
                    message: state.errorMessage!,
                    icons: Icons.error_outline,
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
                        onPressed: () =>
                            _onBuatPesanan(state.nextTransactionNo!),
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

  Widget _buildTrxNoField(OrderState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: semiSecondaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: semiSecondaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.tag_rounded, color: secondaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loading saat fetch
                state.isLoadingTrxNo
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: secondaryColor,
                        ),
                      )
                    : Text(
                        state.nextTransactionNo ?? '-',
                        style: mediumTextStyle.copyWith(
                          color: state.nextTransactionNo != null
                              ? secondaryColor
                              : semiSecondaryColor,
                        ),
                      ),
              ],
            ),
          ),
          // Tombol refresh nomor transaksi
          state.nextTransactionNo != null
              ? SizedBox()
              : GestureDetector(
                  onTap: state.isLoadingTrxNo
                      ? null
                      : () => ref
                            .read(orderViewModelProvider.notifier)
                            .fetchNextTransactionNo(),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: state.isLoadingTrxNo
                        ? semiSecondaryColor.withValues(alpha: 0.3)
                        : primaryColor,
                    size: 20,
                  ),
                ),
        ],
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
