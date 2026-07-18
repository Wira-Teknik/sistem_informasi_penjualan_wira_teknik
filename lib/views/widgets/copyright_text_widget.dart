import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CopyrightTextWidget extends StatelessWidget {
  const CopyrightTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "© ${DateTime.now().year} CV.Wira Teknik.",
      style: regularTextStyle.copyWith(color: semiSecondaryColor, fontSize: 16),
    );
  }
}
