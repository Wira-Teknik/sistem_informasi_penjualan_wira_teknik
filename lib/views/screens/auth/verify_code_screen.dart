import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/verify_code_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_title_logo_widget.dart';

class VerifyCodeScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final _verifyCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _verifyCodeController.dispose();
    super.dispose();
  }

  Future<void> _onVerifyCodePressed() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(verifyCodeViewModelProvider.notifier)
        .verifyCode(widget.email, _verifyCodeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyCodeViewModelProvider);

    // Navigasi ke ResetPassword saat berhasil kirim kode
    ref.listen<VerifyCodeState>(verifyCodeViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        // Reset state sebelum navigasi agar tidak trigger ulang
        ref.read(verifyCodeViewModelProvider.notifier).resetState();

        Navigator.pushReplacementNamed(
          context,
          '/reset_password',
          arguments: {'token': next.token},
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(verifyCodeViewModelProvider.notifier).resetState();
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // title & logo
                CustomTitleLogoWidget(),
                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: semiSecondaryColor.withValues(alpha: 0.5),
                        blurRadius: 0.5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // email textfield
                      CustomTextfield(
                        controller: _verifyCodeController,
                        label: "Kode Verif",
                        hintText: "Masukkan kode verifikasi",
                        keyboardType: TextInputType.number,
                        validator: Validators.verifyCode,
                        onChanged: (_) {
                          // Reset error API saat user mengetik
                          if (state.errorMessage != null) {
                            ref
                                .read(verifyCodeViewModelProvider.notifier)
                                .resetState();
                          }
                        },
                      ),
                      const SizedBox(height: 19),

                      if (state.errorMessage == null)
                        CustomInfoMessageWidget(
                          color: greenColor,
                          message:
                              "Silakan cek email ${widget.email} untuk melihat kode verifikasi",
                          icons: Icons.check_circle_outline_outlined,
                        ),
                      if (state.errorMessage == null)
                        const SizedBox(height: 19),

                      // Error dari API
                      if (state.errorMessage != null)
                        CustomInfoMessageWidget(
                          color: redColor,
                          message: state.errorMessage!,
                          icons: Icons.error_outline_rounded,
                        ),
                      if (state.errorMessage != null)
                        const SizedBox(height: 19),

                      // button login
                      state.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            )
                          : CustomFilledbutton(
                              title: "Lanjut",
                              onPressed: _onVerifyCodePressed,
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // copyright
                Text(
                  "© 2026 CV.Wira Teknik.",
                  style: regularTextStyle.copyWith(
                    color: semiSecondaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
