import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/customer/customer_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/history_transaction/history_transaction_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment_recap/payment_recap_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';

class ManajemenScreen extends ConsumerWidget {
  const ManajemenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginViewModelProvider);
    final role = state.user?.role ?? 'admin';
    final username = state.user?.name;
    final email = state.user?.email;

    return Scaffold(
      appBar: CustomAppbar(title: "Manajemen"),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 17,
          right: 17,
          top: 25,
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // user info
            Text(
              username ?? 'Username',
              style: boldTextStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              email ?? 'Email',
              style: mediumTextStyle.copyWith(color: semiSecondaryColor),
            ),
            const SizedBox(height: 8),
            CustomBadge(label: role.toUpperCase(), badgeColor: primaryColor),
            const SizedBox(height: 24),

            // menu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                    blurRadius: 0.5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AKTIVITAS & LAPORAN",
                    style: boldTextStyle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),
                  const SizedBox(height: 8),

                  ItemActivityReportWidget(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryTransactionScreen(),
                        ),
                      );
                    },
                    imageSource: "assets/icons/history_icon.png",
                    title: "Laporan Riwayat Transaksi",
                    subtitle: "Lihat semua aktivitas transaksi",
                  ),
                  const SizedBox(height: 20),

                  ItemActivityReportWidget(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentRecapScreen(),
                        ),
                      );
                    },
                    imageSource: "assets/icons/recap_icon.png",
                    title: "Rekapitulasi Pembayaran",
                    subtitle: "Rekap informasi seluruh pembayaran",
                  ),
                  const SizedBox(height: 20),

                  if (role == "admin")
                    ItemActivityReportWidget(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerScreen(),
                          ),
                        );
                      },
                      imageSource: "assets/icons/daftar_konsumen.png",
                      title: "Daftar Konsumen",
                      subtitle: "Daftar konsumen cv.wira teknik",
                    ),
                ],
              ),
            ),
            const Spacer(),

            // logout button
            CustomFilledbutton(
              title: "Keluar",
              iconButton: Icons.logout_rounded,
              buttonColor: redColor,
              onPressed: () async {
                ref.read(loginViewModelProvider.notifier).logout().then((
                  value,
                ) {
                  Navigator.pushNamedAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    "/login",
                    ModalRoute.withName("/"),
                  );
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              "CV.WIRA TEKNIK V1.0.0",
              style: regularTextStyle.copyWith(
                fontSize: 12,
                color: semiSecondaryColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemActivityReportWidget extends StatelessWidget {
  final String imageSource;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const ItemActivityReportWidget({
    super.key,
    required this.imageSource,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(imageSource, width: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: semiBoldTextStyle),
              Text(
                subtitle,
                style: regularTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: semiSecondaryColor.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
