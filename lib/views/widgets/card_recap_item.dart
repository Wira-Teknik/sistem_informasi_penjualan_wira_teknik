import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CardRecapItem extends StatelessWidget {
  final String iconSource;
  final String title;
  final String value;
  final bool isArrowIconVisible;
  final Color valueColor;
  final Color arrowIconColor;
  const CardRecapItem({
    super.key,
    required this.iconSource,
    required this.title,
    required this.value,
    this.isArrowIconVisible = false,
    required this.valueColor,
    this.arrowIconColor = primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.5),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconSource, width: 48, height: 48),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: boldTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: boldTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
            ],
          ),
          Spacer(),
          if (isArrowIconVisible)
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: arrowIconColor,
              size: 16,
            ),
        ],
      ),
    );
  }
}
