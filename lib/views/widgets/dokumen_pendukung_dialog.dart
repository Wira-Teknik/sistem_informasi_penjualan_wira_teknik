import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/shipment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/attachment_item.dart';

class DokumenPendukungDialog extends ConsumerWidget {
  final String shipmentId;

  const DokumenPendukungDialog({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shipmentViewModelProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Dokumen Pendukung',
                  style: boldTextStyle.copyWith(fontSize: 14),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: semiSecondaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content
            _buildContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShipmentState state) {
    // Loading
    if (state.isLoadingAttachments) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // Error
    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: redColor, size: 36),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: regularTextStyle.copyWith(color: semiSecondaryColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Filter hanya image dan pdf
    final docs = state.attachments.where((a) => a.isImage || a.isPdf).toList();

    // Kosong
    if (docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                color: semiSecondaryColor,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada dokumen',
                style: regularTextStyle.copyWith(color: semiSecondaryColor),
              ),
            ],
          ),
        ),
      );
    }

    // List dokumen
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: docs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return AttachmentItem(attachment: docs[index]);
        },
      ),
    );
  }
}
