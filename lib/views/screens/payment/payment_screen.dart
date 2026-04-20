import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Pembayaran"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            CustomTextfield(
              hintText: "Cari nama perusahaan",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 22),

            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(
                      left: 1,
                      right: 1,
                      top: 1,
                      bottom: 16,
                    ),
                    padding: const EdgeInsets.all(16),
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
                      children: [
                        // informasi perusahaan dan jumlah pesanan yang harus dibayar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("PT.KIRANA PERMATA", style: boldTextStyle),
                                Text(
                                  "Pesanan yang harus dibayar",
                                  style: mediumTextStyle.copyWith(
                                    fontSize: 10,
                                    color: semiSecondaryColor,
                                  ),
                                ),
                                Text("2", style: boldTextStyle),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "JUMLAH TOTAL",
                                  style: boldTextStyle.copyWith(
                                    fontSize: 10,
                                    color: semiSecondaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),

                                Text(
                                  "Rp 3.120.000",
                                  style: boldTextStyle.copyWith(
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Divider(
                          color: semiSecondaryColor.withValues(alpha: 0.1),
                        ),

                        // pesanan yang harus dibayar
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "P5537XJJ22",
                                    style: boldTextStyle.copyWith(fontSize: 10),
                                  ),
                                  Text(
                                    "Oct 23, 2026",
                                    style: mediumTextStyle.copyWith(
                                      fontSize: 10,
                                      color: semiSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              CustomBadge(
                                label: "Unpaid",
                                badgeColor: redColor,
                              ),
                              const SizedBox(width: 16),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "TOTAL",
                                    style: boldTextStyle.copyWith(
                                      fontSize: 10,
                                      color: semiSecondaryColor.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    "Rp 2.000.000",
                                    style: boldTextStyle.copyWith(
                                      fontSize: 12,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
