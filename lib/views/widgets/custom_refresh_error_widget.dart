import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';

class CustomRefreshErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;
  const CustomRefreshErrorWidget({
    super.key,
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: redColor, size: 40),
            const SizedBox(height: 8),
            Text(
              message,
              style: regularTextStyle.copyWith(color: semiSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 100,
              child: CustomFilledbutton(
                title: "Coba Lagi",
                buttonColor: secondaryColor,
                buttonTitleSize: 12,
                buttonRadius: 100,
                titleButtonColor: whiteColor,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
