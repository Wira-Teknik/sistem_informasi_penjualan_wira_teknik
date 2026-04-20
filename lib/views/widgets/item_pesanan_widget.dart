import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';

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
                    "P5537XJJ22",
                    style: boldTextStyle.copyWith(fontSize: 16),
                  ),
                  Text(
                    "PT.KIRANA PERMATA",
                    style: mediumTextStyle.copyWith(color: semiSecondaryColor),
                  ),
                ],
              ),
              // badge status
              CustomBadge(label: "Pending", badgeColor: primaryColor),
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
