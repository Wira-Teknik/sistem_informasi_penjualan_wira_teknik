import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomFilledbutton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final Color? buttonColor;
  final Color? titleButtonColor;
  final IconData? iconButton;

  const CustomFilledbutton({
    super.key,
    this.onPressed,
    required this.title,
    this.buttonColor,
    this.iconButton,
    this.titleButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(buttonColor ?? primaryColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        // fixedSize: WidgetStateProperty.all(const Size(292, 56)),
        padding: WidgetStateProperty.all(EdgeInsets.only(top: 16, bottom: 16)),
        overlayColor: WidgetStateProperty.all(
          backgroundColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconButton != null) Icon(iconButton, color: whiteColor, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: boldTextStyle.copyWith(
              fontSize: 16,
              color: titleButtonColor ?? whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
