import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/add_payment_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_payment_section.dart';

class DetailPaymentScreen extends StatefulWidget {
  const DetailPaymentScreen({super.key});

  @override
  State<DetailPaymentScreen> createState() => _DetailPaymentScreenState();
}

class _DetailPaymentScreenState extends State<DetailPaymentScreen> {
  int _activeFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Detail Pembayaran'),
      body: Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // informasi pembayaran
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PT.KIRANA PERMATA",
                            style: boldTextStyle.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Belum Dibayar",
                            style: semiBoldTextStyle.copyWith(
                              fontSize: 12,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "Rp 2.500.000",
                            style: boldTextStyle.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      Spacer(),
                      Image.asset("assets/icons/wallet_icon.png", width: 34),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomFilledbutton(
                    title: "Catat Pembayaran",
                    iconButton: Icons.payments_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPaymentScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // aktivitas pembayaran
            Text(
              "Aktivitas Pesanan",
              style: boldTextStyle.copyWith(fontSize: 18),
            ),

            // cari pembayaran
            CustomTextfield(
              hintText: "Cari nomor PO",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 14),

            // filter pembayaran
            FilterPaymentSection(
              onFilterChanged: (index) {
                // update data di parent tanpa rebuild seluruh halaman
                setState(() => _activeFilter = index);
              },
            ),
            const SizedBox(height: 14),
            // list pembayaran
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 1, bottom: 24),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
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
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "P5537XJJ22",
                                  style: boldTextStyle.copyWith(fontSize: 16),
                                ),
                                Text(
                                  "PT.KIRANA PERMATA",
                                  style: mediumTextStyle.copyWith(
                                    fontSize: 14,
                                    color: semiSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),

                            CustomBadge(
                              label: "Partial",
                              badgeColor: orangeColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // tanggal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TANGGAL BELI",
                                  style: boldTextStyle.copyWith(
                                    fontSize: 10,
                                    color: semiSecondaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                Text("Oct 23, 2026", style: mediumTextStyle),
                              ],
                            ),

                            // jumlah total
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "JUMLAH TOTAL",
                                  style: boldTextStyle.copyWith(fontSize: 10),
                                ),
                                Text(
                                  "Rp 2.000.000",
                                  style: boldTextStyle.copyWith(
                                    color: primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Divider(
                          color: semiSecondaryColor.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                icon: ImageIcon(
                                  AssetImage(
                                    "assets/icons/edit_pengiriman_icon.png",
                                  ),
                                  size: 18,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TANGGAL BAYAR",
                                  style: boldTextStyle.copyWith(
                                    fontSize: 10,
                                    color: semiSecondaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                Text("Nov 01, 2026", style: mediumTextStyle),
                              ],
                            ),
                            const Spacer(),

                            Text("Rp 120.000", style: boldTextStyle),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                icon: ImageIcon(
                                  AssetImage(
                                    "assets/icons/edit_pengiriman_icon.png",
                                  ),
                                  size: 18,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TANGGAL BAYAR",
                                  style: boldTextStyle.copyWith(
                                    fontSize: 10,
                                    color: semiSecondaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                Text("Nov 05, 2026", style: mediumTextStyle),
                              ],
                            ),
                            const Spacer(),

                            Text("Rp 500.000", style: boldTextStyle),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Divider(color: secondaryColor),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "JUMLAH SISA",
                                style: boldTextStyle.copyWith(fontSize: 10),
                              ),
                              Text(
                                "Rp 500.000",
                                style: boldTextStyle.copyWith(
                                  color: primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        SizedBox(
                          width: 149,
                          child: CustomFilledbutton(
                            title: "Lihat Bukti Pembayaran",
                            buttonTitleSize: 10,
                            buttonRadius: 100,
                            buttonColor: secondaryColor,
                            onPressed: () {},
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
