import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "CV.Wira Teknik"),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // welcome text
            Text(
              "Selamat datang Admin!",
              style: mediumTextStyle.copyWith(color: semiSecondaryColor),
            ),
            Text("Dashboard", style: boldTextStyle.copyWith(fontSize: 24)),
            const SizedBox(height: 20),

            // card monitoring
            Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runSpacing: 16,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: ItemDashboardAdmin(
                        iconSource: "assets/icons/total_pesanan_icon.png",
                        title: "TOTAL PESANAN",
                        count: "1284",
                        subtitle: "Pesanan",
                      ),
                    ),
                    const SizedBox(width: 18),
                    Flexible(
                      flex: 1,
                      child: ItemDashboardAdmin(
                        iconSource: "assets/icons/dikirim_icon.png",
                        title: "DIKIRIM",
                        count: "24",
                        subtitle: "Dalam Perjalanan",
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: ItemDashboardAdmin(
                        iconSource: "assets/icons/pesanan_selesai_icon.png",
                        title: "PESANAN SELESAI",
                        count: "1110",
                        subtitle: "Selesai",
                      ),
                    ),
                    const SizedBox(width: 18),
                    Flexible(
                      flex: 1,
                      child: ItemDashboardAdmin(
                        iconSource: "assets/icons/belum_bayar_icon.png",
                        title: "BELUM BAYAR",
                        count: "Rp 12.300.000",
                        subtitle: "8 invoices",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // recent activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Aktivitas Terakhir",
                  style: boldTextStyle.copyWith(fontSize: 18),
                ),
                Text(
                  "Lihat Semua",
                  style: semiBoldTextStyle.copyWith(color: primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(left: 1, top: 1, right: 1),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    height: 62,
                    padding: const EdgeInsets.all(13),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: semiSecondaryColor.withValues(alpha: 0.3),
                          blurRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Delivery Confirmed", style: boldTextStyle),
                            Text(
                              "Order P2397DJJ22 delivered",
                              style: regularTextStyle.copyWith(
                                color: semiSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Oct 23, 2026",
                          style: mediumTextStyle.copyWith(
                            color: semiSecondaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDashboardAdmin extends StatelessWidget {
  final String iconSource;
  final String title;
  final String count;
  final String subtitle;

  const ItemDashboardAdmin({
    super.key,
    required this.iconSource,
    required this.title,
    required this.count,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.2),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(iconSource, width: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: boldTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: boldTextStyle.copyWith(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          Text(
            subtitle,
            style: mediumTextStyle.copyWith(
              fontSize: 10,
              color: semiSecondaryColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
