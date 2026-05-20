import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';

abstract class PaymentRepository {
  Future<List<CustomerBillingModel>> getPayments({String? query});
}

class PaymentRepositoryImpl implements PaymentRepository {
  final Dio _dio;
  PaymentRepositoryImpl(this._dio);

  @override
  Future<List<CustomerBillingModel>> getPayments({String? query}) async {
    try {
      final response = await _dio.get(
        '/payments/search-customer',
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
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRepositoryImpl(dio);
});
