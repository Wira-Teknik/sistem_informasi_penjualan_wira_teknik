import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomUploadProofWidget extends StatefulWidget {
  final String label;
  final ValueChanged<File?> onFileSelected; // ← ganti onTap jadi onFileSelected

  const CustomUploadProofWidget({
    super.key,
    required this.label,
    required this.onFileSelected,
  });

  @override
  State<CustomUploadProofWidget> createState() =>
      _CustomUploadProofWidgetState();
}

class _CustomUploadProofWidgetState extends State<CustomUploadProofWidget> {
  File? _selectedFile;
  String? _fileName;
  String? _fileExtension;

  bool get _isPdf => _fileExtension == 'pdf';
  bool get _isImage => ['png', 'jpg', 'jpeg'].contains(_fileExtension);

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      allowMultiple: false,
      allowCompression: true,
      compressionQuality: 30,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final extension = result.files.single.extension?.toLowerCase();
      String fileName = result.files.single.name;

      // --- 1. PROSES KOMPRESI EKSTREM UNTUK GAMBAR ---
      if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
        try {
          final dir = await getTemporaryDirectory();
          final targetPath =
              '${dir.absolute.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$extension';

          // Kompresi dengan menurunkan resolusi (minWidth / minHeight)
          // Ini adalah kunci agar file berukuran MB turun menjadi hitungan ratusan KB
          final compressedXFile = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 30, // Kualitas 60%
            minWidth: 1024, // Maksimal resolusi lebar 1024 pixel
            minHeight: 1024, // Maksimal resolusi tinggi 1024 pixel
          );

          if (compressedXFile != null) {
            file = File(compressedXFile.path);
            fileName = file.path.split('/').last;
            debugPrint(
              '✅ File berhasil dikompresi: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB',
            );
          }
        } catch (e) {
          debugPrint('❌ Gagal melakukan kompresi gambar: $e');
        }
      }

      // --- 2. VALIDASI UKURAN FILE MAKSIMAL 5 MB ---
      // Berlaku untuk gambar yang sudah dikompres maupun PDF
      final fileSizeInBytes = file.lengthSync();
      final fileSizeInMB =
          fileSizeInBytes / (1024 * 1024); // Konversi ke Megabyte

      if (fileSizeInMB > 5.0) {
        // Jika masih di atas 5 MB, hentikan proses dan beritahu user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ukuran file terlalu besar (${fileSizeInMB.toStringAsFixed(1)} MB). Maksimal 5 MB.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Berhenti di sini, jangan kirim file ke parent
      }

      // --- 3. UPDATE STATE & KIRIM KE PARENT ---
      setState(() {
        _selectedFile = file;
        _fileName = fileName;
        _fileExtension = extension;
      });

      widget.onFileSelected(file);
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _fileExtension = null;
    });
    widget.onFileSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: semiBoldTextStyle),
        const SizedBox(height: 6),
        Container(
          height: 210,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: semiSecondaryColor.withValues(alpha: 0.5),
                blurRadius: 0.5,
              ),
            ],
          ),

          // Belum ada file — tampil gambar upload seperti semula
          child: _selectedFile == null
              ? InkWell(
                  onTap: _pickFile,
                  child: Image.asset("assets/images/upload_image.png"),
                )
              : _buildPreview(),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Preview gambar
        if (_isImage)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedFile!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Preview PDF — tidak bisa render langsung
        if (_isPdf)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF Document',
                    style: semiBoldTextStyle.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Nama file + tombol aksi
        Row(
          children: [
            Icon(
              _isPdf ? Icons.picture_as_pdf_rounded : Icons.image_outlined,
              color: primaryColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _fileName ?? '',
                style: regularTextStyle.copyWith(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),

            // Ganti file
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Ganti',
                  style: semiBoldTextStyle.copyWith(
                    fontSize: 10,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Hapus file
            GestureDetector(
              onTap: _removeFile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: redColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Hapus',
                  style: semiBoldTextStyle.copyWith(
                    fontSize: 10,
                    color: redColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
