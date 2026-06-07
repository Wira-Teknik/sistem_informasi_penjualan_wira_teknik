// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/shipment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_upload_proof_widget.dart';

class ConfirmReceivedDialog extends ConsumerStatefulWidget {
  final String shipmentId;
  final VoidCallback onSuccess;

  const ConfirmReceivedDialog({
    super.key,
    required this.shipmentId,
    required this.onSuccess,
  });

  @override
  ConsumerState<ConfirmReceivedDialog> createState() =>
      _ConfirmReceivedDialogState();
}

class _ConfirmReceivedDialogState extends ConsumerState<ConfirmReceivedDialog> {
  File? _selectedFile;

  Future<void> _onKonfirmasi() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomInfoMessageWidget(
            color: redColor,
            message: 'Pilih file bukti terlebih dahulu',
            icons: Icons.error_outline_outlined,
          ),
          backgroundColor: whiteColor,
        ),
      );
      return;
    }

    final success = await ref
        .read(shipmentViewModelProvider.notifier)
        .confirmReceivedWithProof(
          shipmentId: widget.shipmentId,
          proofFile: _selectedFile!,
        );

    if (success && context.mounted) {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomInfoMessageWidget(
            color: greenColor,
            message: 'Barang berhasil dikonfirmasi diterima',
            icons: Icons.done,
          ),
          backgroundColor: whiteColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shipmentViewModelProvider);

    final loadingLabel = state.isConfirming
        ? 'Mengkonfirmasi penerimaan...'
        : state.isUploading
        ? 'Mengupload bukti...'
        : '';

    return PopScope(
      canPop: !state.isConfirming && !state.isUploading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: whiteColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Konfirmasi Terima Barang',
                    style: boldTextStyle.copyWith(fontSize: 14),
                  ),
                  const Spacer(),
                  if (!state.isConfirming && !state.isUploading)
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(shipmentViewModelProvider.notifier)
                            .resetState();
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: semiSecondaryColor,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Upload bukti penerimaan untuk mengkonfirmasi barang telah diterima.',
                style: regularTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),

              const SizedBox(height: 16),
              IgnorePointer(
                // Nonaktifkan interaksi saat loading
                ignoring: state.isConfirming || state.isUploading,
                child: CustomUploadProofWidget(
                  label: "Bukti Penerimaan *",
                  onFileSelected: (file) {
                    setState(() => _selectedFile = file);
                  },
                ),
              ),

              // Error
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                CustomInfoMessageWidget(
                  color: redColor,
                  message: state.errorMessage!,
                  icons: Icons.error_outline_outlined,
                ),
              ],

              const SizedBox(height: 20),

              // Loading indicator
              if (state.isConfirming || state.isUploading) ...[
                LinearProgressIndicator(
                  color: primaryColor,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    loadingLabel,
                    style: regularTextStyle.copyWith(
                      fontSize: 11,
                      color: semiSecondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tombol
              if (!state.isConfirming && !state.isUploading)
                Row(
                  children: [
                    Expanded(
                      child: CustomFilledbutton(
                        title: "Batal",
                        titleButtonColor: semiSecondaryColor,
                        buttonColor: semiSecondaryColor.withValues(alpha: 0.2),
                        buttonTitleSize: 14,
                        onPressed: () {
                          ref
                              .read(shipmentViewModelProvider.notifier)
                              .resetState();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomFilledbutton(
                        title: "Unggah",
                        buttonTitleSize: 14,
                        onPressed: _onKonfirmasi,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
