import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppbar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: boldTextStyle.copyWith(fontSize: 18)),
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: actions,
      bottom: bottom,
      centerTitle: true,
    );
  }
}
