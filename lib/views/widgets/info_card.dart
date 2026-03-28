import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isFullWidth;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withValues(alpha: 0.3),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 18, color: primaryColor),
              SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
