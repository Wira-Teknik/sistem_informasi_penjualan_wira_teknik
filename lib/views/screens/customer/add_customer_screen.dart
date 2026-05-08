import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/customer_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onTambahPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(customerViewModelProvider.notifier)
        .addCustomer(
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
            message: 'Konsumen berhasil ditambahkan',
            icons: Icons.check_circle_outline_outlined,
          ),
          backgroundColor: whiteColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewModelProvider);

    return PopScope(
      canPop: !state.isSubmitting,
      child: Scaffold(
        appBar: CustomAppbar(title: "Tambah Konsumen"),
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

                const SizedBox(height: 12),

                // Tombol tambah
                state.isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : CustomFilledbutton(
                        title: "Tambah Konsumen",
                        iconButton: Icons.save_rounded,
                        buttonRadius: 12,
                        onPressed: _onTambahPressed,
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
