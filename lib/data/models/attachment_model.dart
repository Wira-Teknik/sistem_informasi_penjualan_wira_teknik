import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';

class AttachmentModel {
  final String id;
  final String relatedId;
  final String category;
  final String fileType;
  final String fileUrl;
  final String createdAt;
  final String updatedAt;

  const AttachmentModel({
    required this.id,
    required this.relatedId,
    required this.category,
    required this.fileType,
    required this.fileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // URL lengkap untuk ditampilkan
  String get fullUrl => AppStrings.imageUrl + fileUrl;

  bool get isImage => fileType == 'image';
  bool get isPdf => fileType == 'pdf';

  // Label kategori
  String get categoryLabel => switch (category) {
    'shipment_received' => 'Bukti Terima',
    'shipment_delivery' => 'Bukti Kirim',
    'surat_jalan' => 'Surat Jalan',
    'bon' => 'Bon Pesanan',
    'invoice' => 'Invoice',
    _ => category,
  };

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      AttachmentModel(
        id: json['id'],
        relatedId: json['related_id'],
        category: json['category'],
        fileType: json['file_type'],
        fileUrl: json['file_url'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
}
