// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class EditPaymentDialogWidget extends ConsumerStatefulWidget {
  final String paymentId;
  final String orderId;
  final String invoiceNo;
  final List<PaymentModel> relatedPayments;
  final double currentTotal;
  final VoidCallback onSuccess;

  const EditPaymentDialogWidget({
    super.key,
    required this.paymentId,
    required this.orderId,
    required this.invoiceNo,
    required this.relatedPayments,
    required this.currentTotal,
    required this.onSuccess,
  });

  @override
  ConsumerState<EditPaymentDialogWidget> createState() =>
      _EditPaymentDialogWidgetState();
}

class _EditPaymentDialogWidgetState
    extends ConsumerState<EditPaymentDialogWidget> {
  late final _totalController = TextEditingController(
    text: formatNumberRupiah(widget.currentTotal.toInt().toString()),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _onSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    final newTotal = double.tryParse(_totalController.text.replaceAll('.', ''));
    if (newTotal == null || newTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomInfoMessageWidget(
            color: redColor,
            message: "Total pembayaran tidak valid",
            icons: Icons.error_outline_outlined,
          ),
          backgroundColor: whiteColor,
        ),
      );
      return;
    }

    // Kirim ID Order sebagai List (karena API meminta array)
    final success = await ref
        .read(paymentViewModelProvider.notifier)
        .updatePayment(widget.paymentId, [widget.orderId], newTotal);

    if (success && context.mounted) {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomInfoMessageWidget(
            color: greenColor,
            message: "Pembayaran berhasil diubah",
            icons: Icons.check_rounded,
          ),
          backgroundColor: whiteColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);

    return PopScope(
      canPop: !state.isSubmitting,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: whiteColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Pembayaran',
                      style: boldTextStyle.copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    if (!state.isSubmitting)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close_rounded,
                          color: semiSecondaryColor,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Konteks Invoice
                        Text(
                          'Terkait Invoice:',
                          style: regularTextStyle.copyWith(
                            fontSize: 12,
                            color: semiSecondaryColor,
                          ),
                        ),
                        Text(
                          widget.invoiceNo,
                          style: boldTextStyle.copyWith(
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input total baru
                        Text(
                          'Ubah Nominal',
                          style: semiBoldTextStyle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        CustomTextfield(
                          controller: _totalController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.money_outlined,
                          hintText: '0',
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
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Total wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // List Riwayat Pembayaran (Context)
                        Text(
                          'Riwayat Pembayaran Invoice Ini',
                          style: semiBoldTextStyle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        _buildRelatedPaymentsList(),
                      ],
                    ),
                  ),
                ),

                // Error dari API
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  CustomInfoMessageWidget(
                    color: redColor,
                    message: state.errorMessage!,
                    icons: Icons.error_outline_outlined,
                  ),
                ],

                const SizedBox(height: 20),

                // Loading
                if (state.isSubmitting) ...[
                  LinearProgressIndicator(
                    color: primaryColor,
                    backgroundColor: primaryColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                ],

                // Tombol
                if (!state.isSubmitting)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomFilledbutton(
                        title: "Batal",
                        onPressed: () => Navigator.pop(context),
                        buttonColor: semiSecondaryColor.withValues(alpha: 0.4),
                        buttonRadius: 10,
                        buttonTitleSize: 12,
                      ),
                      const SizedBox(width: 10),
                      CustomFilledbutton(
                        title: "Simpan",
                        onPressed: _onSimpan,
                        buttonColor: primaryColor,
                        buttonRadius: 10,
                        buttonTitleSize: 12,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Menampilkan list data yang terkait dengan invoice_no nya
  Widget _buildRelatedPaymentsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: semiSecondaryColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.relatedPayments.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: semiSecondaryColor.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final payment = widget.relatedPayments[index];
          final isEditingThis = payment.paymentId == widget.paymentId;

          return Container(
            color: isEditingThis
                ? primaryColor.withValues(alpha: 0.05)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.paymentDate,
                        style: boldTextStyle.copyWith(
                          fontSize: 12,
                          color: isEditingThis ? primaryColor : secondaryColor,
                        ),
                      ),
                      if (isEditingThis)
                        Text(
                          "Sedang diubah",
                          style: regularTextStyle.copyWith(
                            fontSize: 10,
                            color: primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  formatRupiah(payment.allocatedAmount),
                  style: boldTextStyle.copyWith(
                    fontSize: 12,
                    color: isEditingThis ? primaryColor : semiSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
