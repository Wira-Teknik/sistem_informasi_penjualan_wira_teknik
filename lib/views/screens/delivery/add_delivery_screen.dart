import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_shipment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/shipment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/barang_dikirim_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_upload_proof_widget.dart';
import 'package:intl/intl.dart';

class AddDeliveryScreen extends ConsumerStatefulWidget {
  final OrderDetailModel order;

  const AddDeliveryScreen({super.key, required this.order});

  @override
  ConsumerState<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends ConsumerState<AddDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  // File uploads
  File? _buktiKirim;
  File? _suratJalan;
  File? _bonPesanan;
  File? _invoiceFile;

  final Map<String, int> _selectedItems = {};

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

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
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Validasi semua file wajib sudah diisi
  String? _validateFiles() {
    if (_buktiKirim == null) return 'Bukti kirim wajib diunggah';
    if (_suratJalan == null) return 'Surat jalan wajib diunggah';
    if (_bonPesanan == null) return 'Bon pesanan wajib diunggah';
    return null;
  }

  // Validasi minimal ada 1 barang dipilih dengan qty > 0
  String? _validateItems() {
    if (_selectedItems.isEmpty) return 'Pilih minimal 1 barang yang dikirim';
    final hasQty = _selectedItems.values.any((qty) => qty > 0);
    if (!hasQty) return 'Jumlah kirim harus lebih dari 0';
    return null;
  }

  Future<void> _onKirimBarang() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi file
    final fileError = _validateFiles();
    if (fileError != null) {
      showSnackbar(context, fileError, isError: true);
      return;
    }

    // Validasi items
    final itemError = _validateItems();
    if (itemError != null) {
      showSnackbar(context, itemError, isError: true);
      return;
    }

    // Build items request
    final items = _selectedItems.entries
        .where((e) => e.value > 0)
        .map(
          (e) => ShipmentItemRequest(orderItemId: e.key, shippingQty: e.value),
        )
        .toList();

    final success = await ref
        .read(shipmentViewModelProvider.notifier)
        .addShipment(
          orderId: widget.order.id,
          shippingDate: _dateController.text,
          items: items,
          buktiKirim: _buktiKirim!,
          suratJalan: _suratJalan!,
          bonPesanan: _bonPesanan!,
          invoiceFile: _invoiceFile,
        );

    if (success && mounted) {
      showSnackbar(context, 'Pengiriman berhasil dibuat', isError: false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shipmentViewModelProvider);

    return PopScope(
      canPop: !state.isSubmitting,
      child: Scaffold(
        appBar: CustomAppbar(title: "Buat Pengiriman"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal kirim
                CustomTextfield(
                  controller: _dateController,
                  label: "Tanggal Kirim",
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Tanggal kirim wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // Bukti kirim (required)
                CustomUploadProofWidget(
                  label: "Bukti Kirim",
                  onFileSelected: (file) => setState(() => _buktiKirim = file),
                ),
                const SizedBox(height: 16),

                // Surat jalan (required)
                CustomUploadProofWidget(
                  label: "Unggah Surat Jalan",
                  onFileSelected: (file) => setState(() => _suratJalan = file),
                ),
                const SizedBox(height: 16),

                // Bon pesanan (required)
                CustomUploadProofWidget(
                  label: "Unggah Bon Pesanan",
                  onFileSelected: (file) => setState(() => _bonPesanan = file),
                ),
                const SizedBox(height: 16),

                // Invoice (optional)
                CustomUploadProofWidget(
                  label: "Unggah Invoice",
                  onFileSelected: (file) => setState(() => _invoiceFile = file),
                ),
                const SizedBox(height: 16),

                // Barang yang dikirim
                BarangDikirimWidget(
                  items: widget.order.items,
                  onItemsChanged: (selected) {
                    setState(() {
                      _selectedItems
                        ..clear()
                        ..addAll(selected);
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Error dari API
                if (state.errorMessage != null)
                  CustomInfoMessageWidget(
                    color: redColor,
                    message: state.errorMessage!,
                    icons: Icons.error_outline,
                  ),

                const SizedBox(height: 24),

                // Tombol kirim
                state.isSubmitting
                    ? Center(
                        child: LinearProgressIndicator(
                          color: primaryColor,
                          backgroundColor: primaryColor.withValues(alpha: 0.2),
                        ),
                      )
                    : CustomFilledbutton(
                        title: "Kirim Barang",
                        iconButton: Icons.edit_note_rounded,
                        buttonRadius: 12,
                        onPressed: _onKirimBarang,
                      ),
                const SizedBox(height: 12),

                CustomFilledbutton(
                  title: "Batalkan",
                  buttonColor: semiSecondaryColor.withValues(alpha: 0.1),
                  titleButtonColor: semiSecondaryColor,
                  buttonRadius: 12,
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
}
