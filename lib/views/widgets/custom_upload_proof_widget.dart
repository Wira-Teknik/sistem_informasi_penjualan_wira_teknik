import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomUploadProofWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const CustomUploadProofWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: semiBoldTextStyle),
        const SizedBox(height: 6),
        Container(
          height: 210,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: semiSecondaryColor.withValues(alpha: 0.5),
                blurRadius: 0.5,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Image.asset("assets/images/upload_image.png"),
          ),
        ),
      ],
    );
  }
}
