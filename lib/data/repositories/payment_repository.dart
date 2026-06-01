import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';

abstract class PaymentRepository {
  Future<List<CustomerBillingModel>> getPayments({String? query});
  Future<List<CustomerBillingModel>> searchCustomerBilling({String? query});
  Future<void> addPayment(AddPaymentRequest request);
  Future<void> updatePayment(String id, double paymentTotal);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final Dio _dio;
  PaymentRepositoryImpl(this._dio);

  @override
  Future<List<CustomerBillingModel>> getPayments({String? query}) async {
    try {
      final response = await _dio.get(
        '/payments',
        queryParameters: query != null && query.isNotEmpty
            ? {'q': query}
            : null,
      );
      final result = CustomerBillingResponseModel.fromJson(response.data);
      return result.data;
    } on DioException catch (e) {
      debugPrint('ERROR BILLING: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat data tagihan');
    }
  }

  @override
  Future<List<CustomerBillingModel>> searchCustomerBilling({
    String? query,
  }) async {
    try {
      // Jika ada query → /payments/customer/{name}
      // Jika kosong   → /payments/customer (get all)
      final endpoint = query != null && query.isNotEmpty
          ? '/payments/customer/${Uri.encodeComponent(query)}'
          : '/payments';

      final response = await _dio.get(endpoint);
      final result = CustomerBillingResponseModel.fromJson(response.data);
      return result.data;
    } on DioException catch (e) {
      debugPrint('ERROR BILLING: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat data tagihan');
    }
  }

  @override
  Future<void> addPayment(AddPaymentRequest request) async {
    try {
      // details dikirim sebagai JSON string sesuai dokumentasi API
      final detailsJson = jsonEncode(
        request.details.map((e) => e.toJson()).toList(),
      );

      final formData = FormData.fromMap({
        'payment_date': request.paymentDate,
        'payment_total': request.paymentTotal,
        'details': detailsJson, // ← JSON string
        'bukti_bayar': await MultipartFile.fromFile(
          request.buktiKirim.path,
          filename: request.buktiKirim.path.split('/').last,
          contentType: _getMediaType(request.buktiKirim.path),
        ),
      });

      await _dio.post(
        '/payments',
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
    } on DioException catch (e) {
      debugPrint('ERROR ADD PAYMENT: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal menyimpan pembayaran');
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
  Future<void> updatePayment(String id, double paymentTotal) async {
    try {
      await _dio.put('/payments/$id', data: {'payment_total': paymentTotal});
    } on DioException catch (e) {
      debugPrint('ERROR UPDATE PAYMENT: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal mengubah pembayaran');
    }
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRepositoryImpl(dio);
});
