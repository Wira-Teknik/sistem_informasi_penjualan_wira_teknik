import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "CV.Wira Teknik"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // welcome text
            Text(
              "Selamat datang Owner!",
              style: mediumTextStyle.copyWith(color: semiSecondaryColor),
            ),
            Text("Dashboard", style: boldTextStyle.copyWith(fontSize: 24)),
            const SizedBox(height: 20),

            // card monitoring
            ItemDashboardOwner(
              backgroundImageUrl:
                  "assets/images/card_pengiriman_berlangsung_image.png",
              title: "PENGIRIMAN BERLANGSUNG",
              value: "142",
              iconUrl: "assets/icons/berlangsung_icon.png",
            ),
            const SizedBox(height: 16),
            ItemDashboardOwner(
              backgroundImageUrl:
                  "assets/images/card_pengiriman_selesai_image.png",
              title: "PENGIRIMAN SELESAI",
              value: "1,420",
              iconUrl: "assets/icons/selesai_icon.png",
            ),
            const SizedBox(height: 16),
            ItemDashboardOwner(
              backgroundImageUrl:
                  "assets/images/card_pesanan_di_proses_image.png",
              title: "PENGIRIMAN DI PROSES",
              value: "25",
              iconUrl: "assets/icons/proses_icon.png",
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
            ListView.builder(
              padding: EdgeInsets.only(left: 1, top: 1, right: 1),
              itemCount: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }
}

class ItemDashboardOwner extends StatelessWidget {
  final String backgroundImageUrl;
  final String title;
  final String value;
  final String iconUrl;
  const ItemDashboardOwner({
    super.key,
    required this.backgroundImageUrl,
    required this.title,
    required this.value,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(backgroundImageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.1),
            blurRadius: 0.1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: boldTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
              Spacer(),
              Image.asset(iconUrl, width: 16, height: 16),
            ],
          ),
          Text(
            value,
            style: boldTextStyle.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
