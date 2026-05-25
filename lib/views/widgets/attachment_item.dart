import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/attachment_model.dart';

class AttachmentItem extends StatelessWidget {
  final AttachmentModel attachment;

  const AttachmentItem({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kategori
        Row(
          children: [
            Icon(
              attachment.isImage
                  ? Icons.image_outlined
                  : Icons.picture_as_pdf_rounded,
              size: 14,
              color: primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              attachment.categoryLabel,
              style: semiBoldTextStyle.copyWith(
                fontSize: 12,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Preview image
        if (attachment.isImage)
          GestureDetector(
            onTap: () => _showFullImage(context, attachment.fullUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                attachment.fullUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: semiSecondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: semiSecondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: semiSecondaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gagal memuat gambar',
                        style: regularTextStyle.copyWith(
                          fontSize: 11,
                          color: semiSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Preview PDF — tidak bisa render, tampil tap to open
        if (attachment.isPdf)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PDF Document',
                        style: semiBoldTextStyle.copyWith(color: Colors.red),
                      ),
                      Text(
                        attachment.fileUrl.split('/').last,
                        style: regularTextStyle.copyWith(
                          fontSize: 11,
                          color: Colors.red.shade300,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Full screen image viewer
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
                child: Image.network(imageUrl, fit: BoxFit.contain),
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
                  child: Icon(Icons.close_rounded, color: whiteColor, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
