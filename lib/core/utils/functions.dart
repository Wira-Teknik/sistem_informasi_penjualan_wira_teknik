import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:url_launcher/url_launcher.dart';

String formatRupiah(int value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  ).format(value);
}

String formatNumberRupiah(String value) {
  final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return '';
  final number = int.tryParse(clean) ?? 0;

  return NumberFormat('#,##0', 'id_ID').format(number);
}

String formatDateDisplay(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('d MMM yyyy').format(date);
}

void showSnackbar(
  BuildContext context,
  String message, {
  required bool isError,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: CustomInfoMessageWidget(
        color: isError ? redColor : greenColor,
        message: message,
        icons: isError ? Icons.error_outline_outlined : Icons.check_rounded,
      ),
      backgroundColor: whiteColor,
    ),
  );
}

String formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('MMM dd, yyyy').format(date);
  } catch (_) {
    return dateStr;
  }
}

Future<void> openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.parse(AppStrings.imageUrl + url);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomInfoMessageWidget(
            color: Colors.red,
            message: 'Tidak bisa membuka file/tautan',
            icons: Icons.error_outline_outlined,
          ),
          backgroundColor: Colors.white,
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomInfoMessageWidget(
          color: Colors.red,
          message: 'Terjadi kesalahan: $e',
          icons: Icons.error_outline_outlined,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

Future<DateTime?> pickCustomDate(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2050),
    builder: (context, child) => Theme(
      data: Theme.of(
        context,
      ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
      child: child!,
    ),
  );

  return picked;
}
