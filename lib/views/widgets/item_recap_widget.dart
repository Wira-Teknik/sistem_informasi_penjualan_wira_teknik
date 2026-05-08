import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';

class ItemRecapWidget extends StatelessWidget {
  final String noPO;
  final String namaKonsumen;
  final String badgeName;
  final Color badgeColor;
  final String tanggal;
  final String jumlahTotal;
  const ItemRecapWidget({
    super.key,
    required this.noPO,
    required this.namaKonsumen,
    required this.badgeName,
    required this.badgeColor,
    required this.tanggal,
    required this.jumlahTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, top: 1, bottom: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(noPO, style: boldTextStyle.copyWith(fontSize: 16)),
                  Text(
                    namaKonsumen,
                    style: mediumTextStyle.copyWith(color: semiSecondaryColor),
                  ),
                ],
              ),
              // badge status
              CustomBadge(label: badgeName, badgeColor: badgeColor),
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
                  Text(tanggal, style: mediumTextStyle),
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
                    jumlahTotal,
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
