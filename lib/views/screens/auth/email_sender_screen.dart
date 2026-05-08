import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/email_sender_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_title_logo_widget.dart';

class EmailSenderScreen extends ConsumerStatefulWidget {
  const EmailSenderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EmailSenderScreenState();
}

class _EmailSenderScreenState extends ConsumerState<EmailSenderScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onKirimKodePressed() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(emailSenderViewModelProvider.notifier)
        .forgotPassword(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailSenderViewModelProvider);

    // Navigasi ke VerifyCodeScreen saat berhasil kirim email
    ref.listen<EmailSenderState>(emailSenderViewModelProvider, (
      previous,
      next,
    ) {
      if (next.isSuccess) {
        // Reset state sebelum navigasi agar tidak trigger ulang
        ref.read(emailSenderViewModelProvider.notifier).resetState();

        Navigator.pushReplacementNamed(
          context,
          '/verify_code',
          arguments: {"email": _emailController.text},
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(emailSenderViewModelProvider.notifier).resetState();
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
                        controller: _emailController,
                        label: "Email",
                        hintText: "Masukkan email Anda",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        onChanged: (_) {
                          // Reset error API saat user mengetik
                          if (state.errorMessage != null) {
                            ref
                                .read(emailSenderViewModelProvider.notifier)
                                .resetState();
                          }
                        },
                      ),
                      const SizedBox(height: 19),

                      // Error dari API
                      if (state.errorMessage != null)
                        CustomInfoMessageWidget(
                          color: redColor,
                          message: state.errorMessage!,
                          icons: Icons.error_outline_rounded,
                        ),
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
                              title: "Kirim Kode",
                              onPressed: state.isLoading
                                  ? null
                                  : _onKirimKodePressed,
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
