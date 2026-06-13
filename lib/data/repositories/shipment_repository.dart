import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_shipment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/attachment_model.dart';

abstract class ShipmentRepository {
  Future<void> addShipment(AddShipmentRequest request);
  Future<void> confirmReceived(String shipmentId);
  Future<void> uploadAttachment({
    required String relatedId,
    required File file,
    required String category,
  });
  Future<List<AttachmentModel>> getAttachments(String shipmentId);
  Future<void> updateShipment(
    String shipmentId,
    List<Map<String, dynamic>> items,
  );
}

class ShipmentRepositoryImpl implements ShipmentRepository {
  final Dio _dio;

  ShipmentRepositoryImpl(this._dio);

  @override
  Future<void> addShipment(AddShipmentRequest request) async {
    try {
      final itemsJson = jsonEncode(
        request.items.map((e) => e.toJson()).toList(),
      );

      final formData = FormData.fromMap({
        'order_id': request.orderId,
        'shipping_date': request.shippingDate,
        'items': itemsJson,
        'bukti_kirim': await MultipartFile.fromFile(
          request.buktiKirim.path,
          filename: request.buktiKirim.path.split('/').last,
          contentType: _getMediaType(request.buktiKirim.path),
        ),
        'surat_jalan': await MultipartFile.fromFile(
          request.suratJalan.path,
          filename: request.suratJalan.path.split('/').last,
          contentType: _getMediaType(request.suratJalan.path),
        ),
        'bon_pesanan': await MultipartFile.fromFile(
          request.bonPesanan.path,
          filename: request.bonPesanan.path.split('/').last,
          contentType: _getMediaType(request.bonPesanan.path),
        ),
        'invoice_file': await MultipartFile.fromFile(
          request.invoiceFile.path,
          filename: request.invoiceFile.path.split('/').last,
          contentType: _getMediaType(request.invoiceFile.path),
        ),
      });

      await _dio.post(
        '/shipments',
        data: formData,
        // ← Override timeout khusus untuk upload file
        options: Options(
          sendTimeout: const Duration(minutes: 2), // kirim file ke server
          receiveTimeout: const Duration(minutes: 2), // tunggu response server
        ),
        // ← Monitor progress upload
        onSendProgress: (sent, total) {
          if (total != -1) {
            final percent = (sent / total * 100).toStringAsFixed(0);
            debugPrint('Upload progress: $percent%');
          }
        },
      );
    } on DioException catch (e) {
      debugPrint('ERROR SHIPMENT: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal membuat pengiriman');
    }
  }

  DioMediaType _getMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf' => DioMediaType('application', 'pdf'),
      'png' => DioMediaType('image', 'png'),
      'jpg' || 'jpeg' => DioMediaType('image', 'jpeg'),
      _ => DioMediaType('application', 'octet-stream'),
    };
  }

  @override
  Future<void> confirmReceived(String shipmentId) async {
    try {
      await _dio.patch('/shipments/$shipmentId/received');
    } on DioException catch (e) {
      debugPrint('ERROR CONFIRM: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal konfirmasi penerimaan');
    }
  }

  @override
  Future<void> uploadAttachment({
    required String relatedId,
    required File file,
    required String category,
  }) async {
    try {
      final formData = FormData.fromMap({
        'related_id': relatedId,
        'category': category,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: _getMediaType(file.path),
        ),
      });

      await _dio.post(
        '/attachments',
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
    } on DioException catch (e) {
      debugPrint('ERROR UPLOAD: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal mengunggah bukti');
    }
  }

  @override
  Future<List<AttachmentModel>> getAttachments(String shipmentId) async {
    try {
      final response = await _dio.get(
        '${AppStrings.attachmentsEndpoint}/$shipmentId',
      );
      final data = response.data['data'] as List;
      return data.map((e) => AttachmentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('ERROR GET ATTACHMENTS: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat dokumen');
    }
  }

  @override
  Future<void> updateShipment(
    String shipmentId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      await _dio.put('/shipments/$shipmentId', data: {'items': items});
    } on DioException catch (e) {
      debugPrint('ERROR UPDATE SHIPMENT: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal mengubah pengiriman');
    }
  }
}

final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ShipmentRepositoryImpl(dio);
});
