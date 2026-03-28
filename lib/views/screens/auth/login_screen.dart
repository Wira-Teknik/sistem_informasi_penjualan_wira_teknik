import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/bottom_navigation.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // email textfield
                  CustomTextfield(
                    label: "Email Address",
                    hintText: "yourmail@example.com",
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // password textfield
                  CustomTextfield(
                    label: "Password",
                    hintText: "••••••••",
                    prefixIcon: Icons.lock_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(height: 45),

                  // button login
                  CustomFilledbutton(
                    title: "Login to Dashboard",
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNavigation(),
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
