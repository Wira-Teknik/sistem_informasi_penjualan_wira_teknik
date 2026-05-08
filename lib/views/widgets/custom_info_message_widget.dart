import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomInfoMessageWidget extends StatelessWidget {
  final Color color;
  final String message;
  final IconData icons;
  const CustomInfoMessageWidget({
    super.key,
    required this.color,
    required this.message,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icons, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: regularTextStyle.copyWith(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
