import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    // Pantau state — navigasi begitu isLoading selesai
    ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
      if (next.isLoading) return; // masih loading, tunggu

      if (next.isSuccess) {
        // Sudah ada sesi → langsung ke dashboard
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/bottom_navigation',
          (route) => false,
        );
      } else {
        // Belum login → ke halaman login
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      body: Center(
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
