import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_upload_proof_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/menunggu_pembayaran_widget.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final CustomerBillingDetailModel billing; // ← terima dari DetailPaymentScreen

  const AddPaymentScreen({super.key, required this.billing});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _totalController = TextEditingController();

  File? _buktiKirim;
  List<BillingOrderModel> _selectedOrders = [];

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

  Future<void> _onSimpanPembayaran() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrders.isEmpty) {
      showSnackbar(
        context,
        'Pilih minimal 1 pesanan yang akan dibayar',
        isError: true,
      );
      return;
    }

    if (_buktiKirim == null) {
      showSnackbar(context, 'Bukti bayar wajib diunggah', isError: true);
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
      showSnackbar(context, 'Pembayaran berhasil disimpan', isError: false);
      Navigator.pop(context, true);
    }
  }

  // Auto-fill total dari order yang dipilih
  void _onOrdersChanged(List<BillingOrderModel> orders) {
    setState(() => _selectedOrders = orders);

    // Auto-fill total
    final total = orders.fold<int>(0, (sum, o) => sum + o.remainingBalance);
    if (total > 0) {
      _totalController.text = formatNumberRupiah(total.toString());
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
                    final formatted = formatNumberRupiah(value);
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
                          formatRupiah(
                            _selectedOrders.fold<int>(
                              0,
                              (sum, o) => (sum + o.totalAmountToPay).toInt(),
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
                  CustomInfoMessageWidget(
                    color: redColor,
                    message: state.errorMessage!,
                    icons: Icons.error_outline,
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
