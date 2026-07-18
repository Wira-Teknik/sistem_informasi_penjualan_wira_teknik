import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/validators.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/auth/email_sender_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/copyright_text_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_title_logo_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // setup input
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['expired'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomInfoMessageWidget(
              color: orangeColor,
              message: 'Sesi Anda telah berakhir, silakan login kembali',
              icons: Icons.lock_clock_outlined,
            ),
            backgroundColor: whiteColor,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // action on login press
  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(loginViewModelProvider.notifier)
        .login(_usernameController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);

    ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
      if (next.isSuccess && previous?.isSuccess != true) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/bottom_navigation',
          (route) => false,
        );
      }
    });

    return Scaffold(
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
                      controller: _usernameController,
                      validator: Validators.username,
                      onChanged: (p0) => ref
                          .read(loginViewModelProvider.notifier)
                          .clearError(),
                      label: "Username",
                      hintText: "Username",
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // password textfield
                    CustomTextfield(
                      controller: _passwordController,
                      validator: Validators.password,
                      onChanged: (_) => ref
                          .read(loginViewModelProvider.notifier)
                          .clearError(),
                      label: "Password",
                      hintText: "••••••••",
                      prefixIcon: Icons.lock_outlined,
                      obscureText: true,
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailSenderScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Lupa Password!",
                        style: mediumTextStyle.copyWith(color: primaryColor),
                      ),
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
                            title: "Masuk ke Dashboard",
                            onPressed: state.isLoading ? null : _onLoginPressed,
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // copyright
              CopyrightTextWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
