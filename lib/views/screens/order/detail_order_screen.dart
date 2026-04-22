import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';

class DetailOrderScreen extends StatelessWidget {
  const DetailOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Detail Pesanan",
        actions: [
          IconButton(
            onPressed: () {
              // aksi edit pesanan
            },
            icon: ImageIcon(
              AssetImage("assets/icons/edit_pesanan.png"),
              color: secondaryColor,
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // informasi pesanan
            Container(
              height: 114,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/icons/box_icon.png",
                            width: 18,
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "No Transaksi",
                            style: semiBoldTextStyle.copyWith(
                              fontSize: 12,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "TXN-8842",
                        style: boldTextStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Updated: Oct 23, 2026 • 14:30",
                        style: regularTextStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  Spacer(),
                  CustomBadge(label: "Pending", badgeColor: primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // informasi konsumen
            Text("INFORMASI KONSUMEN", style: boldTextStyle),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/company_icon.png",
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PT.KIRANA PERMATA", style: boldTextStyle),
                          Text(
                            "No PO: P5537XJJ22",
                            style: regularTextStyle.copyWith(
                              fontSize: 12,
                              color: semiSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    "Budisantoso@mail.com",
                    style: regularTextStyle.copyWith(color: semiSecondaryColor),
                  ),

                  const SizedBox(height: 10),
                  Divider(color: semiSecondaryColor.withValues(alpha: 0.2)),
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/icons/location_icon.png",
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Kawasan Industri Jababeka II, Jl. Industri Selatan No. 12, Bekasi, West Java 17530",
                          style: regularTextStyle.copyWith(
                            color: semiSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // informasi barang
            Text("BARANG PESANAN (3)", style: boldTextStyle),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Industrial Bearing 6205", style: semiBoldTextStyle),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Rp 1.100.000",
                            style: boldTextStyle.copyWith(color: primaryColor),
                          ),
                          const Spacer(),
                          Text(
                            "x 1",
                            style: boldTextStyle.copyWith(color: primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Divider(color: semiSecondaryColor.withValues(alpha: 0.2)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // informasi status pembayaran
            Text("STATUS PEMBAYARAN", style: boldTextStyle),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Status Sekarang", style: semiBoldTextStyle),
                      Spacer(),
                      CustomBadge(label: "Unpaid", badgeColor: redColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "JUMLAH TOTAL",
                        style: boldTextStyle.copyWith(
                          fontSize: 12,
                          color: semiSecondaryColor,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Rp 2.000.000",
                        style: boldTextStyle.copyWith(color: primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // informasi pengiriman
            Text("PENGIRIMAN", style: boldTextStyle),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage("assets/icons/edit_pengiriman_icon.png"),
                            size: 18,
                            color: secondaryColor,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomBadge(label: "Dikirim", badgeColor: yellowColor),
                      Spacer(),
                      Text(
                        "Oct 23, 2026 • 14:30",
                        style: regularTextStyle.copyWith(
                          fontSize: 12,
                          color: semiSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Industrial Bearing 6205",
                            style: semiBoldTextStyle,
                          ),
                          Spacer(),
                          Text(
                            "x 1",
                            style: semiBoldTextStyle.copyWith(
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomFilledbutton(
                        title: "Dokumen Pendukung",
                        buttonColor: secondaryColor,
                        buttonRadius: 20,
                        buttonTitleSize: 10,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 10),
                      CustomFilledbutton(
                        title: "Unggah Bukti",
                        buttonRadius: 20,
                        buttonTitleSize: 10,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // button pengiriman
            CustomFilledbutton(
              title: "Buat Pengiriman",
              iconButton: Icons.edit_note_rounded,
              onPressed: () {
                // aksi buat pengiriman
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
