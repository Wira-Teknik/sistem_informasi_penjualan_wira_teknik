import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/order_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class EditOrderScreen extends ConsumerStatefulWidget {
  final OrderDetailModel order;
  const EditOrderScreen({super.key, required this.order});

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _poNoController;
  late final TextEditingController _orderDateController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _poNoController = TextEditingController(text: widget.order.poNo);
    _orderDateController = TextEditingController(text: widget.order.orderDate);
    _nameController = TextEditingController(text: widget.order.recipientName);
    _phoneController = TextEditingController(text: widget.order.recipientPhone);
    _emailController = TextEditingController(text: widget.order.recipientEmail);
    _addressController = TextEditingController(
      text: widget.order.recipientAddress,
    );
  }

  @override
  void dispose() {
    _poNoController.dispose();
    _orderDateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _poNoController.text.trim() != widget.order.poNo ||
      _orderDateController.text.trim() != widget.order.orderDate ||
      _nameController.text.trim() != widget.order.recipientName ||
      _phoneController.text.trim() != widget.order.recipientPhone ||
      _emailController.text.trim() != widget.order.recipientEmail ||
      _addressController.text.trim() != widget.order.recipientAddress;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.order.orderDate) ?? DateTime.now(),
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
      _orderDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _onSimpanPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomInfoMessageWidget(
            color: primaryColor,
            message: 'Tidak ada perubahan data',
            icons: Icons.info_outline_rounded,
          ),
          backgroundColor: whiteColor,
        ),
      );
      return;
    }

    final success = await ref
        .read(orderViewModelProvider.notifier)
        .updateOrder(widget.order.id, {
          'po_no': _poNoController.text.trim().toUpperCase(),
          'order_date': _orderDateController.text.trim(),
          'recipient_name': _nameController.text.trim(),
          'recipient_phone': _phoneController.text.trim(),
          'recipient_email': _emailController.text.trim(),
          'recipient_address': _addressController.text.trim(),
        });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomInfoMessageWidget(
            color: greenColor,
            message: "Pesanan berhasil diubah",
            icons: Icons.check_rounded,
          ),
          backgroundColor: whiteColor,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<bool> _onBackPressed() async {
    if (!_hasChanges) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buang Perubahan?'),
        content: const Text(
          'Ada perubahan yang belum disimpan. Yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Keluar', style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (state.isSubmitting) return;
        final canLeave = await _onBackPressed();
        if (canLeave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: CustomAppbar(title: "Edit Pesanan"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Detail Pesanan ──────────────────────
                _buildSectionHeader(
                  "assets/icons/order_detail_icon.png",
                  "DETAIL PESANAN",
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _poNoController,
                  label: "Nomor PO",
                  prefixIcon: Icons.content_paste_outlined,
                  readOnly: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nomor PO wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _orderDateController,
                  label: "Tanggal Pesan",
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tanggal wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                // ── Informasi Konsumen ──────────────────
                _buildSectionHeader(
                  "assets/icons/customer_information_icon.png",
                  "INFORMASI KONSUMEN",
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _nameController,
                  label: "Nama Konsumen",
                  prefixIcon: Icons.badge_outlined,
                  readOnly: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _phoneController,
                  label: "Nomor Telepon",
                  prefixIcon: Icons.phone_outlined,
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
                const SizedBox(height: 12),

                // Error dari API
                if (state.errorMessage != null)
                  CustomInfoMessageWidget(
                    color: redColor,
                    message: state.errorMessage!,
                    icons: Icons.error_outline,
                  ),

                const SizedBox(height: 24),

                state.isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : CustomFilledbutton(
                        title: "Simpan Perubahan",
                        iconButton: Icons.save_rounded,
                        buttonRadius: 12,
                        onPressed: _onSimpanPressed,
                      ),
                const SizedBox(height: 12),

                CustomFilledbutton(
                  title: "Batalkan",
                  buttonColor: semiSecondaryColor.withValues(alpha: 0.1),
                  titleButtonColor: semiSecondaryColor,
                  buttonRadius: 12,
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final canLeave = await _onBackPressed();
                          if (canLeave && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
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
