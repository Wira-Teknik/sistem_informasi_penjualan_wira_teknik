import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/customer_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class EditCustomerScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const EditCustomerScreen({super.key, required this.customer});

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    // Pre-fill form dengan data customer yang ada
    _nameController = TextEditingController(text: widget.customer.customerName);
    _phoneController = TextEditingController(
      text: widget.customer.customerPhone,
    );
    _emailController = TextEditingController(
      text: widget.customer.customerEmail,
    );
    _addressController = TextEditingController(
      text: widget.customer.customerAddress,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Cek apakah ada perubahan data dari data awal
  bool get _hasChanges =>
      _nameController.text.trim() != widget.customer.customerName ||
      _phoneController.text.trim() != widget.customer.customerPhone ||
      _emailController.text.trim() != widget.customer.customerEmail ||
      _addressController.text.trim() != widget.customer.customerAddress;

  Future<void> _onSimpanPressed() async {
    if (!_formKey.currentState!.validate()) return;

    // Tidak perlu hit API jika tidak ada perubahan
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomInfoMessageWidget(
            color: greenColor,
            message: 'Tidak ada perubahan data',
            icons: Icons.check_circle_outline_outlined,
          ),
          backgroundColor: whiteColor,
        ),
      );
      return;
    }

    final success = await ref
        .read(customerViewModelProvider.notifier)
        .updateCustomer(
          id: widget.customer.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomInfoMessageWidget(
            color: greenColor,
            message: 'Data konsumen berhasil diubah',
            icons: Icons.check_circle_outline_outlined,
          ),
          backgroundColor: whiteColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _onBackPressed() async {
    if (!_hasChanges) return true;

    // Tampil konfirmasi jika ada perubahan yang belum disimpan
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buang Perubahan?'),
        content: const Text(
          'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
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
    final state = ref.watch(customerViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (state.isSubmitting) return;

        final canLeave = await _onBackPressed();
        if (canLeave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: CustomAppbar(title: "Edit Konsumen"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextfield(
                  controller: _nameController,
                  label: "Nama Konsumen",
                  prefixIcon: Icons.badge_outlined,
                  hintText: 'PT....',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama konsumen wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextfield(
                  controller: _phoneController,
                  label: "Nomor Telepon",
                  prefixIcon: Icons.phone_outlined,
                  hintText: "08....",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon wajib diisi';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Error dari API
                if (state.errorMessage != null)
                  CustomInfoMessageWidget(
                    color: redColor,
                    message: state.errorMessage!,
                    icons: Icons.error_outline,
                  ),

                const SizedBox(height: 12),

                // Tombol simpan
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

                // Tombol batal
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
}
