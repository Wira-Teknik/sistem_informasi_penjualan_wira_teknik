import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomTitleLogoWidget extends StatelessWidget {
  const CustomTitleLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/banner_mitra.png', width: 120),
          Text(
            "CV.Wira Teknik",
            style: semiBoldTextStyle.copyWith(fontSize: 20),
          ),
          Text(
            "Sistem Informasi Penjualan",
            style: regularTextStyle.copyWith(
              fontSize: 16,
              color: semiSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
