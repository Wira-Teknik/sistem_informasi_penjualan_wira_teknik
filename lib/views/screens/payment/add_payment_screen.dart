import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_upload_proof_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/menunggu_pembayaran_widget.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final CustomerBillingModel billing; // ← terima dari DetailPaymentScreen

  const AddPaymentScreen({super.key, required this.billing});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _totalController = TextEditingController();

  File? _buktiKirim;
  List<OrderModel> _selectedOrders = [];

  @override
  void dispose() {
    _dateController.dispose();
    _totalController.dispose();
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

  // Format angka rupiah saat mengetik
  String _formatNumber(String value) {
    final clean = value.replaceAll('.', '');
    if (clean.isEmpty) return '';
    final number = int.tryParse(clean) ?? 0;
    return NumberFormat('#,###', 'id_ID').format(number);
  }

  Future<void> _onSimpanPembayaran() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrders.isEmpty) {
      _showSnackbar('Pilih minimal 1 pesanan yang akan dibayar', isError: true);
      return;
    }

    if (_buktiKirim == null) {
      _showSnackbar('Bukti bayar wajib diunggah', isError: true);
      return;
    }

    // Hitung total dari remaining balance order yang dipilih
    final paymentTotal = _selectedOrders.fold<double>(
      0,
      (sum, o) => sum + o.remainingBalance,
    );

    final request = AddPaymentRequest(
      paymentDate: _dateController.text.trim(),
      paymentTotal:
          double.tryParse(_totalController.text.replaceAll('.', '')) ??
          paymentTotal,
      details: _selectedOrders
          .map((o) => AddPaymentDetailRequest(orderId: o.id))
          .toList(),
      buktiKirim: _buktiKirim!,
    );

    final success = await ref
        .read(paymentViewModelProvider.notifier)
        .addPayment(request);

    if (success && mounted) {
      _showSnackbar('Pembayaran berhasil disimpan', isError: false);
      Navigator.pop(context, true);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? redColor : Colors.green,
      ),
    );
  }

  // Auto-fill total dari order yang dipilih
  void _onOrdersChanged(List<OrderModel> orders) {
    setState(() => _selectedOrders = orders);

    // Auto-fill total
    final total = orders.fold<int>(0, (sum, o) => sum + o.remainingBalance);
    if (total > 0) {
      _totalController.text = _formatNumber(total.toString());
    } else {
      _totalController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);

    return PopScope(
      canPop: !state.isSubmitting,
      child: Scaffold(
        appBar: CustomAppbar(title: "Catat Pembayaran"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal bayar
                CustomTextfield(
                  controller: _dateController,
                  label: "Tanggal Bayar",
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tanggal wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Total jumlah uang
                CustomTextfield(
                  controller: _totalController,
                  label: "Total Jumlah Uang",
                  prefixIcon: Icons.money_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Total wajib diisi' : null,
                  onChanged: (value) {
                    final formatted = _formatNumber(value);
                    if (formatted != value) {
                      _totalController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Upload bukti bayar
                CustomUploadProofWidget(
                  label: "Unggah Bukti Bayar *",
                  onFileSelected: (file) => setState(() => _buktiKirim = file),
                ),
                const SizedBox(height: 16),

                // List order menunggu pembayaran
                MenungguPembayaranWidget(
                  billing: widget.billing,
                  onOrdersChanged: _onOrdersChanged,
                ),
                const SizedBox(height: 16),

                // Info total yang dipilih
                if (_selectedOrders.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_selectedOrders.length} pesanan dipilih",
                          style: semiBoldTextStyle.copyWith(fontSize: 13),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(
                            _selectedOrders.fold<int>(
                              0,
                              (sum, o) => sum + o.remainingBalance,
                            ),
                          ),
                          style: boldTextStyle.copyWith(
                            color: primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Error dari API
                if (state.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
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

                const SizedBox(height: 24),

                // Tombol simpan
                state.isSubmitting
                    ? Column(
                        children: [
                          LinearProgressIndicator(
                            color: primaryColor,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Menyimpan pembayaran...',
                              style: regularTextStyle.copyWith(
                                fontSize: 12,
                                color: semiSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : CustomFilledbutton(
                        title: "Simpan Pembayaran",
                        iconButton: Icons.save_outlined,
                        buttonRadius: 12,
                        onPressed: _onSimpanPembayaran,
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
