import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_model.dart';

abstract class PaymentRecapRepository {
  Future<PaymentRecapModel> getRecap({
    String? startDate,
    String? endDate,
    String? search,
  });
}

class PaymentRecapRepositoryImpl implements PaymentRecapRepository {
  final Dio _dio;

  PaymentRecapRepositoryImpl(this._dio);

  @override
  Future<PaymentRecapModel> getRecap({
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      // Hanya kirim parameter yang tidak kosong
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/payment-recap',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PaymentRecapModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('ERROR RECAP: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat rekapitulasi pembayaran');
    }
  }
}

final paymentRecapRepositoryProvider = Provider<PaymentRecapRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRecapRepositoryImpl(dio);
});
