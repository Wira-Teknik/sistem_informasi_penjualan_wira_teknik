import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Pesanan"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            CustomTextfield(
              hintText: "Search orders, customers, or IDs",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ItemPesananWidget();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        backgroundColor: primaryColor,
        child: Icon(Icons.add_rounded, color: whiteColor),
      ),
    );
  }
}

class ItemPesananWidget extends StatelessWidget {
  const ItemPesananWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, top: 1, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "P2397DJJ22",
                    style: boldTextStyle.copyWith(fontSize: 16),
                  ),
                  Text(
                    "PT.Maju Jaya",
                    style: regularTextStyle.copyWith(color: semiSecondaryColor),
                  ),
                ],
              ),
              // badge status
              CustomBadge(label: "Processing", badgeColor: primaryColor),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // tanggal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TANGGAL",
                    style: boldTextStyle.copyWith(
                      fontSize: 10,
                      color: semiSecondaryColor.withValues(alpha: 0.5),
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
                    style: boldTextStyle.copyWith(
                      fontSize: 10,
                      color: semiSecondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    "Rp 12.750.000",
                    style: boldTextStyle.copyWith(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
