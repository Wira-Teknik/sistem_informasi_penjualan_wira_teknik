import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_title_logo_widget.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
      if (next.isLoading) return;

      if (next.isTokenExpired) {
        // Token expired → login dengan pesan
        _navigateToLogin(showExpiredMessage: true);
        return;
      }

      if (next.isSuccess) {
        // Sesi valid → ke dashboard
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/bottom_navigation',
          (route) => false,
        );
      } else {
        // Belum login → ke login
        _navigateToLogin(showExpiredMessage: false);
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTitleLogoWidget(),
            const SizedBox(height: 40),
            LinearProgressIndicator(
              color: primaryColor,
              backgroundColor: primaryColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin({required bool showExpiredMessage}) {
    Navigator.pushReplacementNamed(
      context,
      '/login',
      arguments: showExpiredMessage ? {'expired': true} : null,
    );
  }
}
