import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';

String formatRupiah(int value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);
}

String formatNumberRupiah(String value) {
  final clean = value.replaceAll('.', '');
  if (clean.isEmpty) return '';
  final number = int.tryParse(clean) ?? 0;
  return NumberFormat('#,###', 'id_ID').format(number);
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
