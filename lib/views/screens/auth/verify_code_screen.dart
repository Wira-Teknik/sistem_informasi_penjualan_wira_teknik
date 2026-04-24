import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/auth/reset_password_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // title & logo
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/icons/truck_icon.png',
                    width: 33,
                    height: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "CV.Wira Teknik",
                    style: semiBoldTextStyle.copyWith(fontSize: 20),
                  ),
                  Text(
                    "Sistem Informasi Penjualan",
                    style: regularTextStyle.copyWith(
                      fontSize: 16,
                      color: semiSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                    label: "Kode Verif",
                    hintText: "Masukkan kode verifikasi",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 19),

                  // button login
                  CustomFilledbutton(
                    title: "Lanjut",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
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
    );
  }
}
