import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/reset_password_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_title_logo_widget.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSimpanPressed() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(resetPasswordViewModelProvider.notifier)
        .resetPassword(
          _confirmPasswordController.text,
          _passwordController.text,
          widget.token,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordViewModelProvider);

    // Navigasi ke login saat berhasil reset password
    ref.listen<ResetPasswordState>(resetPasswordViewModelProvider, (
      previous,
      next,
    ) {
      if (next.isSuccess) {
        ref.read(resetPasswordViewModelProvider.notifier).resetState();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomInfoMessageWidget(
              color: greenColor,
              message: 'Password berhasil diubah, silakan login kembali',
              icons: Icons.check_circle_outline_outlined,
            ),
            backgroundColor: whiteColor,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(resetPasswordViewModelProvider.notifier).resetState();
        ref.read(loginViewModelProvider.notifier).resetState();
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
                        controller: _passwordController,
                        label: "Password",
                        hintText: "••••••••",
                        prefixIcon: Icons.lock_outlined,
                        obscureText: true,
                        validator: Validators.password,
                        onChanged: (_) => ref
                            .read(resetPasswordViewModelProvider.notifier)
                            .resetState(),
                      ),
                      const SizedBox(height: 16),

                      // password textfield
                      CustomTextfield(
                        controller: _confirmPasswordController,
                        label: "Confirm Password",
                        hintText: "••••••••",
                        prefixIcon: Icons.lock_outlined,
                        obscureText: true,
                        validator: (value) {
                          Validators.password;
                          if (value != _passwordController.text) {
                            return 'Password tidak sama';
                          }

                          return null;
                        },
                        onChanged: (_) => ref
                            .read(resetPasswordViewModelProvider.notifier)
                            .resetState(),
                      ),
                      const SizedBox(height: 19),

                      if (state.errorMessage != null)
                        CustomInfoMessageWidget(
                          color: redColor,
                          message: state.errorMessage!,
                          icons: Icons.error_outline,
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
                              title: "Simpan Password",
                              onPressed: _onSimpanPressed,
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
