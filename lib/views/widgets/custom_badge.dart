import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomBadge extends StatelessWidget {
  final String label;
  final Color badgeColor;
  const CustomBadge({super.key, required this.label, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Badge(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      label: Text(
        label,
        style: semiBoldTextStyle.copyWith(fontSize: 12, color: badgeColor),
      ),
      backgroundColor: badgeColor.withValues(alpha: 0.2),
    );
  }
}
