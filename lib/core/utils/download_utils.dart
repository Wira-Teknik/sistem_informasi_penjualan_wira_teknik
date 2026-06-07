import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';

class DownloadUtils {
  DownloadUtils._();

  static Future<void> downloadAndOpen({
    required BuildContext context,
    required Dio dio,
    required String endpoint,
    required String fileName,
    Map<String, dynamic>? queryParams,
  }) async {
    // Tampil loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DownloadingDialog(fileName: fileName),
    );

    try {
      // Ambil direktori download
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      // Download file
      await dio
          .get(
            endpoint,
            queryParameters: queryParams,
            options: Options(
              responseType: ResponseType.bytes,
              receiveTimeout: const Duration(minutes: 2),
            ),
            onReceiveProgress: (received, total) {
              if (total != -1) {
                debugPrint(
                  'Download: ${(received / total * 100).toStringAsFixed(0)}%',
                );
              }
            },
          )
          .then((response) async {
            final file = File(filePath);
            await file.writeAsBytes(response.data);
          });

      // Tutup loading dialog
      if (context.mounted) Navigator.pop(context);

      // Buka file
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomInfoMessageWidget(
              color: orangeColor,
              message: 'Tidak bisa membuka file: ${result.message}',
              icons: Icons.warning_amber_rounded,
            ),
            backgroundColor: whiteColor,
          ),
        );
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomInfoMessageWidget(
              color: redColor,
              message: e.error?.toString() ?? 'Gagal mengunduh file',
              icons: Icons.error_outline,
            ),
            backgroundColor: whiteColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomInfoMessageWidget(
              color: redColor,
              message: 'Terjadi kesalahan: $e',
              icons: Icons.error_outline,
            ),
            backgroundColor: whiteColor,
          ),
        );
      }
    }
  }
}

class _DownloadingDialog extends StatelessWidget {
  final String fileName;

  const _DownloadingDialog({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Mengunduh File...',
              style: boldTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              fileName,
              style: regularTextStyle.copyWith(
                fontSize: 12,
                color: semiSecondaryColor,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
