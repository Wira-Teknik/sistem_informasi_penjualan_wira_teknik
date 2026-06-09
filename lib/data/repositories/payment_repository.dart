import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/response/customer_billing_response_model.dart';

abstract class PaymentRepository {
  Future<List<CustomerBillingModel>> getCustomerBillings({
    String? query,
    String? startDate,
    String? endDate,
    String? status,
  });
  Future<CustomerBillingDetailModel> getCustomerBillingDetail(
    String customerName,
  );
  Future<void> addPayment(AddPaymentRequest request);
  Future<void> updatePayment(String id, double paymentTotal);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final Dio _dio;
  PaymentRepositoryImpl(this._dio);

  @override
  Future<List<CustomerBillingModel>> getCustomerBillings({
    String? query,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    try {
      final endpoint = query != null && query.isNotEmpty
          ? '/payments/customer/${Uri.encodeComponent(query)}'
          : '/payments';

      final Map<String, dynamic> queryParams = {};

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final result = CustomerBillingResponseModel.fromJson(response.data);
      return result.data;
    } on DioException catch (e) {
      debugPrint('ERROR BILLING: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat data tagihan');
    }
  }

  @override
  Future<CustomerBillingDetailModel> getCustomerBillingDetail(
    String customerName,
  ) async {
    try {
      final response = await _dio.get(
        '/payments/customer/${Uri.encodeComponent(customerName)}',
      );

      return CustomerBillingDetailModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('ERROR CUSTOMER DETAIL: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat detail tagihan customer');
    }
  }

  @override
  Future<void> addPayment(AddPaymentRequest request) async {
    try {
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
