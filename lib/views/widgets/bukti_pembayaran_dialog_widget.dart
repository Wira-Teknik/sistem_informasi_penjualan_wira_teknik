import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/attachment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/shipment_repository.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';

class BuktiPembayaranDialogWidget extends ConsumerStatefulWidget {
  final List<PaymentModel> payments;

  const BuktiPembayaranDialogWidget({super.key, required this.payments});

  @override
  ConsumerState<BuktiPembayaranDialogWidget> createState() =>
      _BuktiPembayaranDialogWidgetState();
}

class _BuktiPembayaranDialogWidgetState
    extends ConsumerState<BuktiPembayaranDialogWidget> {
  // Simpan attachments per payment id
  final Map<String, List<AttachmentModel>> _attachmentsMap = {};
  final Map<String, bool> _loadingMap = {};
  final Map<String, String?> _errorMap = {};

  @override
  void initState() {
    super.initState();
    // Load semua attachment tiap payment saat dialog dibuka
    for (final payment in widget.payments) {
      _loadAttachment(payment.id);
    }
  }

  Future<void> _loadAttachment(String paymentId) async {
    setState(() {
      _loadingMap[paymentId] = true;
      _errorMap[paymentId] = null;
    });

    try {
      final attachments = await ref
          .read(shipmentRepositoryProvider)
          .getAttachments(paymentId);

      setState(() {
        _attachmentsMap[paymentId] = attachments
            .where((a) => a.isImage || a.isPdf)
            .toList();
        _loadingMap[paymentId] = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMap[paymentId] = e.toString().replaceAll('Exception: ', '');
        _loadingMap[paymentId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.receipt_outlined, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Bukti Pembayaran',
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
            const SizedBox(height: 4),
            Text(
              '${widget.payments.length} riwayat pembayaran',
              style: regularTextStyle.copyWith(
                fontSize: 12,
                color: semiSecondaryColor,
              ),
            ),

            const SizedBox(height: 12),
            Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),

            // List per payment
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.payments.length,
                separatorBuilder: (_, _) =>
                    Divider(color: semiSecondaryColor.withValues(alpha: 0.1)),
                itemBuilder: (context, index) {
                  final payment = widget.payments[index];
                  return _PaymentBuktiSection(
                    payment: payment,
                    attachments: _attachmentsMap[payment.id] ?? [],
                    isLoading: _loadingMap[payment.id] ?? true,
                    errorMessage: _errorMap[payment.id],
                    formatRupiah: formatRupiah,
                    onRetry: () => _loadAttachment(payment.id),
                    onImageTap: (url) => _showFullImage(context, url),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat gambar',
                          style: regularTextStyle.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section per payment
class _PaymentBuktiSection extends StatelessWidget {
  final PaymentModel payment;
  final List<AttachmentModel> attachments;
  final bool isLoading;
  final String? errorMessage;
  final String Function(int) formatRupiah;
  final VoidCallback onRetry;
  final ValueChanged<String> onImageTap;

  const _PaymentBuktiSection({
    required this.payment,
    required this.attachments,
    required this.isLoading,
    required this.errorMessage,
    required this.formatRupiah,
    required this.onRetry,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.paymentDate,
                    style: semiBoldTextStyle.copyWith(fontSize: 12),
                  ),

                  Text(
                    '${payment.details.length} invoice dialokasikan',
                    style: regularTextStyle.copyWith(
                      fontSize: 11,
                      color: semiSecondaryColor,
                    ),
                  ),
                ],
              ),
              Text(
                formatRupiah(payment.paymentTotal.toInt()),
                style: boldTextStyle.copyWith(
                  color: primaryColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Loading
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          // Error
          else if (errorMessage != null)
            CustomRefreshErrorWidget(message: errorMessage!, onPressed: onRetry)
          // Tidak ada attachment
          else if (attachments.isEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: semiSecondaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: semiSecondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Belum ada bukti pembayaran',
                    style: regularTextStyle.copyWith(
                      fontSize: 12,
                      color: semiSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          // Tampil attachment
          else
            Column(
              children: attachments.map((attachment) {
                if (attachment.isImage) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => onImageTap(attachment.fullUrl),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              attachment.fullUrl,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: semiSecondaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryColor,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, _, _) => Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: semiSecondaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: semiSecondaryColor,
                                ),
                              ),
                            ),
                          ),
                          // Icon zoom
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // PDF
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.red,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            attachment.fullUrl.split('/').last,
                            style: regularTextStyle.copyWith(
                              fontSize: 11,
                              color: Colors.red.shade400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
